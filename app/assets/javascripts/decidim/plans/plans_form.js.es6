// = require decidim/plans/character_counter
// = require decidim/plans/tab_focus
// = require decidim/plans/multifield
// = require decidim/plans/reset_inputs
// = require decidim/plans/info_modals
// = require_self

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

  $(() => {
    $("form.plans-form").each((_i, el) => {
      const $form = $(el);

      $("[data-remaining-characters]", $form).remainingCharacters();
      $(".multifield-fields", $form).multifield();

      $("[data-field-toggle]", $form).each((_j, toggleEl) => {
        const $field = $(toggleEl);
        const $targets = $($field.data("field-toggle"));
        $field.on("change.decidim-plans, init.decidim-plans", () => {
          $targets.addClass("hide");
          $targets.filter(`[data-field-toggle-value="${$field.val()}"]`).removeClass("hide");
        }).trigger("init.decidim-plans");
      });
      $(".address-input", $form).each((_j, addressEl) => {
        bindAddressLookup($(addressEl));
      });
    });
  });
})(window);
