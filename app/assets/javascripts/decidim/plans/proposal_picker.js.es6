// = require jquery.auto-complete

// = require_self

$(function() {
  $(document).on(
    "open.zf.reveal", "#data_picker-modal",

    /* @this HTMLElement */
    function () {
      let xhr = null;

      // Fix the position so that the autocomplete works
      $("html").css("top", "");
      $("#data_picker-autocomplete").each((_i, el) => {
        const parentId = `autocomplete-container-${Math.random().toString(36).substr(2, 9)}`;

        const $el = $(el);
        const $parent = $el.parent();

        $parent.attr("id", parentId);

        $el.autoComplete({
          minChars: 2,
          source: function(term, response) {
            try {
              xhr.abort();
            } catch (exception) { xhr = null; }

            let url = $("#proposal-picker-choose").attr("href");
            xhr = $.getJSON(
              url,
              { term: term },
              (data) => { response(data); }
            );
          },
          renderItem: function (item, search) {
            let sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
            let re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
            let title = item[0].replace(/"/g, "&quot;");
            let modelId = item[1];
            return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${title}">${title.replace(re, "<b>$1</b>")}</div>`;
          },
          onSelect: function(_event, _term, item) {
            let choose = $("#proposal-picker-choose");
            let modelId = item.data("modelId");
            let val = item.data("val");
            choose.data("picker-value", modelId);
            choose.data("picker-text", val);
            choose.data("picker-choose", "");
          }
        });
      });

      // Remove all the empty values after the selection is made to prevent
      // these empty values appearing in the list.
      // This is needed until the following is merged to the core:
      // https://github.com/decidim/decidim/pull/4842
      const $choose = $("#proposal-picker-choose", this);
      $choose.on("click", function() {
        const $values = $("#plan_proposals .picker-values");
        $("input[type='checkbox']", $values).each(function(_ev, input) {
          const $input = $(input);
          if ($input.val().length < 1) {
            $input.parent().remove();
          }
        });
      });
    }
  );
});
