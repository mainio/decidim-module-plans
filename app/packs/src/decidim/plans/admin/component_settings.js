$(() => {
  const showHideAnswer = () => {
    const val = $("#component_settings_default_state").val();

    let $label = $("label[for='component_settings_default_answer']").parent();
    let $editor = $("[data-tabs-content='global-settings-default_answer-tabs']");

    // Only one language available
    if ($label.length < 1) {
      $label = $("label[for^='component_settings_default_answer']");
      $editor = $label.parent();
    }

    if (val.length > 0) {
      $label.show();
      $editor.show();
    } else {
      $label.hide();
      $editor.hide();

      if (typeof Quill === "undefined") {
        return;
      }

      // Reset the quill content
      $(".editor-container", $editor).each((_i, el) => {
        const quill = Quill.find(el);
        if (typeof quill === "undefined") {
          return;
        }

        quill.setText("");
      });
    }
  }

  $("#component_settings_default_state").on("change", () => {
    showHideAnswer();
  });
  showHideAnswer();
});
