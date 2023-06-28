((exports) => {
  const $ = exports.$; // eslint-disable-line

  const listId = "plans_list";
  const filterId = "plans_filter";
  const noDataId = "no_plans";

  $(() => {
    const $content = $(".picker-content"),
        pickerMore = $content.data("picker-more"),
        pickerPath = $content.data("picker-path"),
        toggleNoData = () => {
          const showNoData = $(`#${listId} li:visible`).length === 0;
          $(`#${noDataId}`).toggle(showNoData);
        }

    let jqxhr = null;

    toggleNoData();

    $(".data_picker-modal-content").on("change keyup", `#${filterId}`, (event) => {
      const filter = event.target.value.toLowerCase();

      if (pickerMore) {
        if (jqxhr !== null) {
          jqxhr.abort();
        }

        $content.html("<div class='loading-spinner'></div>");
        jqxhr = $.get(`${pickerPath}?q=${filter}`, (data) => {
          $content.html(data);
          jqxhr = null;
          toggleNoData();
        });
      } else {
        $(`#${listId} li`).each((_i, li) => {
          $(li).toggle(li.textContent.toLowerCase().indexOf(filter) > -1);
        });
        toggleNoData();
      }
    });
  });
})(window);
