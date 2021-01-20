((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

  const initMultifield = ($wrapper) => {
    const wrapperSelector = `#${$wrapper.attr("id")}`;
    const placeholderId = $wrapper.data("placeholder-id");
    const isSingle = $wrapper.data("multifield-type") === "single";

    const fieldSelector = ".multifield-field";

    const autoLabelByPosition = new AutoLabelByPositionComponent({
      listSelector: `${wrapperSelector} .multifield-field:not(.hidden)`,
      labelSelector: ".multifield-title .multifield-title-text",
      onPositionComputed: (el, idx) => {
        $(el).find("input.position-input").val(idx);
      }
    });

    const autoButtonsByPosition = new AutoButtonsByPositionComponent({
      listSelector: `${wrapperSelector} .multifield-field:not(.hidden)`,
      hideOnFirstSelector: ".move-up-field",
      hideOnLastSelector: ".move-down-field"
    });

    const createSortableList = () => {
      createSortList(`${wrapperSelector} .fields-list:not(.published)`, {
        handle: ".multifield-field-divider",
        placeholder: '<div style="border-style: dashed; border-color: #000"></div>',
        forcePlaceholderSize: true,
        onSortUpdate: () => { autoLabelByPosition.run() }
      });
    };

    const hideDeletedSection = ($target) => {
      const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val();

      if (inputDeleted === "true") {
        $target.addClass("hidden");
        $target.hide();
      }
    }

    createDynamicFields({
      placeholderId: placeholderId,
      wrapperSelector: wrapperSelector,
      containerSelector: ".multifield-fields-list",
      fieldSelector: fieldSelector,
      addFieldButtonSelector: ".add-field",
      removeFieldButtonSelector: ".remove-field",
      moveUpFieldButtonSelector: ".move-up-field",
      moveDownFieldButtonSelector: ".move-down-field",
      onAddField: () => {
        createSortableList();

        autoLabelByPosition.run();
        autoButtonsByPosition.run();

        if (isSingle) {
          $(".add-field", $wrapper).addClass("hide");
        }
      },
      onRemoveField: ($removedField) => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();

        // Move the field to be the first one in the list because otherwise
        // it may mess up the ordering buttons, causing them sometimes not to
        // move the element if the removed field is in-between.
        $removedField.parent().prepend($removedField);

        if (isSingle) {
          $(".add-field", $wrapper).removeClass("hide");
        }
      },
      onMoveUpField: () => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      },
      onMoveDownField: () => {
        autoLabelByPosition.run();
        autoButtonsByPosition.run();
      }
    });

    createSortableList();

    $(fieldSelector).each((_i, el) => {
      const $target = $(el);

      hideDeletedSection($target);
    });

    autoLabelByPosition.run();
    autoButtonsByPosition.run();

    if (isSingle && $(`${wrapperSelector} ${fieldSelector}:not(.hide)`).length > 0) {
      $(".add-field", $wrapper).addClass("hide");
    }
  }

  $.fn.multifield = function() {
    $(this).each((_i, el) => {
      const $elem = $(el);
      let id = $elem.attr("id");
      if (!id || id.length < 1) {
        id = `multifield-${Math.random().toString(16).slice(2)}`;
        $elem.attr("id", id);
      }
      initMultifield($elem);
    });
  }
})(window);
