$(() => {
  const $search = $("#data_picker-autocomplete");
  const $results = $("#plan-tags-results");
  const $template = $(".decidim-template", $results);
  const $form = $search.parents("form");
  const addRowItem = function(id, title) {
    let template = $template.html();
    template = template.replace(new RegExp("{{tag_id}}", "g"), id);
    template = template.replace(new RegExp("{{tag_name}}", "g"), title);
    const $newRow = $(template);
    $("table tbody", $results).append($newRow);
    $results.removeClass("hide");

    // Add it to the autocomplete form
    const $field = $(`<input type="hidden" name="tags[]" value="${id}">`);
    $form.append($field);

    // Listen to the click event on the remove button
    $(".remove-tagging", $newRow).on("click", function(ev) {
      ev.preventDefault();
      $newRow.remove();
      $field.remove();

      if ($("table tbody tr", $results).length < 1) {
        $results.addClass("hide");
      }
    });
  };
  let xhr = null;
  let currentSearch = "";

  $search.on("keyup", function() {
    currentSearch = $search.val();
  });

  $search.autoComplete({
    minChars: 2,
    cache: 0,
    source: function(term, response) {
      try {
        xhr.abort();
      } catch (exception) { xhr = null; }

      const url = $form.attr("action");
      xhr = $.getJSON(
        url,
        $form.serializeArray(),
        function(data) {
          if (data.length > 0) {
            response(data);
          } else {
            response([
              [null, $search.data("no-results-text"), term]
            ]);
          }
        }
      );
    },
    renderItem: function (item, search) {
      const sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
      const re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
      const modelId = item[0];
      const title = item[1];
      const val = `${title}`;

      if (modelId === null) {
        // Empty result
        const term = item[2];
        const url = $search.data("no-results-url").replace("{{term}}", encodeURIComponent(term));
        return `<div><a href="${url}">${val.replace("{{term}}", term)}</a></div>`;
      }
      return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${title}">${val.replace(re, "<b>$1</b>")}</div>`;
    },
    onSelect: function(event, term, item) {
      const $suggestions = $search.data("sc");
      const modelId = item.data("modelId");
      const title = item.data("val");

      addRowItem(modelId, title);

      $search.val(currentSearch);
      setTimeout(function() {
        $(`[data-model-id="${modelId}"]`, $suggestions).remove();
        $suggestions.show();
      }, 20);
    }
  });

  const resultsArray = $results.data("results");
  if (Array.isArray(resultsArray)) {
    resultsArray.forEach((value) => {
      addRowItem(value[0], value[1]);
    });
  }
});
