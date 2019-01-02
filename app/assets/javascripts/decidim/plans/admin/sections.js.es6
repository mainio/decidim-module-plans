((exports) => {
  const { AutoLabelByPositionComponent, AutoButtonsByPositionComponent, createDynamicFields, createSortList } = exports.DecidimAdmin;

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

  createDynamicFields({
    placeholderId: "section-id",
    wrapperSelector: wrapperSelector,
    containerSelector: ".sections-list",
    fieldSelector: fieldSelector,
    addFieldButtonSelector: ".add-section",
    removeFieldButtonSelector: ".remove-section",
    moveUpFieldButtonSelector: ".move-up-section",
    moveDownFieldButtonSelector: ".move-down-section",
    onAddField: () => {
      createSortableList();

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

  $(fieldSelector).each((idx, el) => {
    const $target = $(el);

    hideDeletedSection($target);
  });

  autoLabelByPosition.run();
  autoButtonsByPosition.run();
})(window);
