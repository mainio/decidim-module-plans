((exports) => {
  const {
    AutoLabelByPositionComponent,
    AutoButtonsByPositionComponent,
    createDynamicFields,
    createSortList
  } = exports.DecidimAdmin;
  const { createQuillEditor } = exports.Decidim;

  const wrapperSelector = ".plan-sections";
  const fieldSelector = ".plan-section";

  const autoLabelByPosition = new AutoLabelByPositionComponent({
    listSelector: ".plan-section:not(.hidden)",
    labelSelector: ".card-title span:first",
    onPositionComputed: (el, idx) => {
      $(el).find("input[name$=\\[position\\]]").val(idx);
    }
  });

  const autoButtonsByPosition = new AutoButtonsByPositionComponent({
    listSelector: ".plan-section:not(.hidden)",
    hideOnFirstSelector: ".move-up-section",
    hideOnLastSelector: ".move-down-section"
  });

  const createSortableList = () => {
    createSortList(".sections-list:not(.published)", {
      handle: ".section-divider",
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

  const setupSection = ($target) => {
    const $sectionTypeSelect = $("select[name$='[section_type]']", $target);

    $sectionTypeSelect.on("change init", () => {
      const activeType = $sectionTypeSelect.val();

      $(".section-type-controls", $target).each((_i, controls) => {
        $(controls).children().each((_j, item) => {
          const $control = $(item);
          const applyTypes = $control.data("section-type");
          const inverseTypes = $control.data("section-type-inverse");

          if (inverseTypes) {
            if (inverseTypes.includes(activeType)) {
              $control.addClass("hide");
            } else {
              $control.removeClass("hide");
            }
          } else if (applyTypes) {
            if (applyTypes.includes(activeType)) {
              $control.removeClass("hide");
            } else {
              $control.addClass("hide");
            }
          }
        });
      });
    }).trigger("init");
  };

  // The data picker field names are transferred through the data-name attribute
  // which is not properly handled by the Decidim dynamic fields generator.
  const fixDataPickerFieldNames = ($field) => {
    const fieldUniqueId = $field.attr("id").match(/section_([0-9]+)-field/)[1];

    $(".data-picker", $field).each((_i, el) => {
      const $picker = $(el);
      const fieldName = $picker.data("picker-name").replace("section-id", fieldUniqueId);
      $picker.attr("data-picker-name", fieldName).data("picker-name", fieldName);

      // Add default value so the value is available in the POST data even
      // when no scope is picked. The selected scope will override this with
      // the same name (and later in the document).
      $picker.prepend(`<input type="hidden" name="${fieldName}" value="0" />`);
    })
  }

  createDynamicFields({
    placeholderId: "section-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".sections-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-section",
    removeFieldButtonSelector: ".remove-section",
    moveUpFieldButtonSelector: ".move-up-section",
    moveDownFieldButtonSelector: ".move-down-section",
    onAddField: ($field) => {
      createSortableList();
      setupSection($field);
      $(".data-picker", $field).each((_i, el) => {
        exports.theDataPicker.activate($(el));
      })
      fixDataPickerFieldNames($field);
      $(".editor-container", $field).each((_idx, container) => {
        createQuillEditor(container);
      });

      autoLabelByPosition.run();
      autoButtonsByPosition.run();
    },
    onRemoveField: () => {
      autoLabelByPosition.run();
      autoButtonsByPosition.run();
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

  $(fieldSelector).each((_idx, el) => {
    const $target = $(el);

    setupSection($target);
    fixDataPickerFieldNames($target);
    hideDeletedSection($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
