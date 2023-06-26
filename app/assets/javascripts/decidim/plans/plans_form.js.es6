// = require decidim/plans/character_counter
// = require decidim/plans/tab_focus
// = require decidim/plans/multifield
// = require decidim/plans/plans_form_attachments
// = require decidim/plans/reset_inputs
// = require decidim/plans/info_modals
// = require_self

((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  // Defines whether the user can exit the view without a warning or not
  let canExit = false;

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

    // Listen for the autocompletion event from Tribute
    $address.on("tribute-replaced", (ev) => {
      const selected = ev.detail.item.original;
      if (selected.coordinates) {
        $latitude.val(selected.coordinates[0]).attr("value", selected.coordinates[0]);
        $longitude.val(selected.coordinates[1]).attr("value", selected.coordinates[1]);

        $map.trigger("coordinates.decidim-plans", [{
          lat: selected.coordinates[0],
          lng: selected.coordinates[1]
        }]);
      } else {
        performCoordinatesLookup();
      }
    });

    $lookup.on("click.decidim-plans", (ev) => {
      ev.preventDefault();
      performCoordinatesLookup();
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
    const $discardLink = $(".discard-draft-link", $form);
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

          canExit = true;
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

    $discardLink.off("click.decidim-plans.form").on(
      "click.decidim-plans.form",
      () => {
        canExit = true;
      }
    );
  };

  const bindAccidentalExitDisabling = () => {
    $(document).on("click", "a, input, button", (ev) => {
      const $target = $(ev.target);
      if ($target.closest(".idea-form-container").length > 0) {
        canExit = true;
      } else if ($target.closest(".plan-form-container").length > 0) {
        canExit = true;
      } else if ($target.closest("#loginModal").length > 0) {
        canExit = true;
      }
    });

    window.onbeforeunload = () => {
      if (canExit) {
        return null;
      }

      return "";
    }
  };

  $(() => {
    bindAccidentalExitDisabling();

    $("form.plans-form").each((_i, el) => {
      const $form = $(el);

      $(".multifield-fields", $form).multifield();
      $(".attachments-section", $form).attachmentfield();

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
