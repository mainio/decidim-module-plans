import "src/decidim/plans/character_counter";
import "src/decidim/plans/tab_focus";
import "src/decidim/plans/reset_inputs";
import "src/decidim/plans/info_modals";
import "src/decidim/plans/exit_handler";

((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  const bindAddressLookup = ($container) => {
    const $map = $(".plans-map");
    const $address = $(".address-input-address", $container);
    const $latitude = $(".address-input-latitude", $container);
    const $longitude = $(".address-input-longitude", $container);
    const $lookup = $(".address-input-lookup", $container);
    const authToken = $("input[name='authenticity_token']").val();
    const coordinatesUrl = $address.data("coordinates-url");
    const addressUrl = $address.data("address-url");

    const performAddressLookup = () => {
      $.ajax({
        method: "POST",
        url: addressUrl,
        data: {
          authenticity_token: authToken, // eslint-disable-line camelcase
          lat: $latitude.val(),
          lng: $longitude.val()
        },
        dataType: "json"
      }).done((resp) => {
        if (resp.success) {
          $address.val(resp.result.address);
        }
      });
    };

    const performCoordinatesLookup = () => {
      $.ajax({
        method: "POST",
        url: coordinatesUrl,
        data: {
          authenticity_token: authToken, // eslint-disable-line camelcase
          address: $address.val()
        },
        dataType: "json"
      }).done((resp) => {
        if (resp.success) {
          $latitude.val(resp.result.lat);
          $longitude.val(resp.result.lng);

          $map.trigger("coordinates.decidim-plans", [{
            lat: resp.result.lat,
            lng: resp.result.lng
          }]);
        }
      });
    }

    const announceMarkerAdded = ($field) => {
      // This is a method that is not available by default but it can be added.
      // See:
      // https://github.com/decidim/decidim/pull/12707
      if (!window.Decidim.announceForScreenReader) {
        return;
      }

      const message = $field.data("screen-reader-announcement");
      window.Decidim.announceForScreenReader(message);
    }

    // Prevent the form submit event on keydown event in the address field
    $address.on("keydown.decidim-plans", (ev) => {
      if (ev.keyCode === 13) {
        ev.preventDefault();
      }
    });
    // Perform lookup only on the keyup event so that we will not perform
    // multiple searches if enter is kept down.
    $address.on("keyup.decidim-plans", (ev) => {
      if (ev.keyCode === 13) {
        performCoordinatesLookup();
      }
    });
    // The address field can be reset in which case we should also reset the
    // map marker.
    $address.on("change.decidim-plans", () => {
      if ($address.val() === "") {
        $map.trigger("coordinates.decidim-plans", [null]);
      }
    });

    // When we receive coordinates from the map, update the relevant coordinate
    // fields and perform address lookup.
    $address.on("coordinates.decidim-plans", (_ev, coordinates) => {
      $latitude.val(coordinates.lat).attr("value", coordinates.lat);
      $longitude.val(coordinates.lng).attr("value", coordinates.lng);

      performAddressLookup();
    });

    // When we receive the specify event from the map, this means the user moved
    // the marker specifying a more exact position. Update the relevant
    // coordinate fields but do not perform.
    $address.on("specify.decidim-plans", (_ev, coordinates) => {
      $latitude.val(coordinates.lat).attr("value", coordinates.lat);
      $longitude.val(coordinates.lng).attr("value", coordinates.lng);
    });

    // Listen for the autocompletion event from AutocompleteJS
    const autocomplete = $address[0].ac;
    $address[0].addEventListener("selection", (ev) => {
      autocomplete.close();

      const selected = ev.detail?.selection?.value;
      if (selected && selected.coordinates) {
        $latitude.val(selected.coordinates[0]).attr("value", selected.coordinates[0]);
        $longitude.val(selected.coordinates[1]).attr("value", selected.coordinates[1]);

        $map.trigger("coordinates.decidim-plans", [{
          lat: selected.coordinates[0],
          lng: selected.coordinates[1]
        }]);
      } else {
        performCoordinatesLookup();
      }
      announceMarkerAdded($address);
    });

    $lookup.on("click.decidim-plans", (ev) => {
      ev.preventDefault();
      autocomplete.close();
      performCoordinatesLookup();
      announceMarkerAdded($address);
    });

    if ($latitude.val().length > 0 && $longitude.val().length > 0) {
      $map.trigger("coordinates.decidim-plans", [{
        lat: $latitude.val(),
        lng: $longitude.val()
      }]);
    }
  };

  /**
   * In later Foundation versions, this is already handled by Foundation core.
   *
   * This validates the form on submit as it does not work with the Foundation
   * version that currently ships with Decidin.
   *
   * @param {jQuery} $form The form for which to bind.
   * @returns {undefined}
   */
  const bindFormValidation = ($form) => {
    const $submits = $("[type='submit']", $form);
    const $submitMessage = $(".form-submit-message", $form);

    $submits.off("click.decidim-plans.form").on(
      "click.decidim-plans.form",
      (ev) => {
        // Tell the backend which submit button was pressed (save or preview)
        let $btn = $(ev.target);
        if (!$btn.is("button")) {
          $btn = $btn.closest("button");
        }

        $form.append(`<input type="hidden" name="save_type" value="${$btn.attr("name")}" />`);
        $submits.attr("disabled", true);

        if (!ev.key || (ev.key === " " || ev.key === "Enter")) {
          ev.preventDefault();

          $form.submit();

          const $firstField = $("input.is-invalid-input, textarea.is-invalid-input, select.is-invalid-input").first();
          if ($firstField.length > 0) {
            $firstField.focus();
            $submits.removeAttr("disabled");
          } else {
            // Show the submit message.
            $submitMessage.removeClass("hide");
          }
        }
      }
    );
  };

  $(() => {
    $("form.plans-form").each((_i, el) => {
      const $form = $(el);

      $("[data-field-toggle]", $form).each((_j, toggleEl) => {
        const $field = $(toggleEl);
        const $targets = $($field.data("field-toggle"));
        $field.on("change.decidim-plans, init.decidim-plans", () => {
          $targets.addClass("hide");
          $("input, textarea, select", $targets).prop("disabled", true);

          const $current = $targets.filter(`[data-field-toggle-value="${$field.val()}"]`);
          $current.removeClass("hide");
          $("input, textarea, select", $current).prop("disabled", false);
        }).trigger("init.decidim-plans");
      });
      $(".address-input", $form).each((_j, addressEl) => {
        bindAddressLookup($(addressEl));
      });

      bindFormValidation($form);
    });
  });
})(window);
