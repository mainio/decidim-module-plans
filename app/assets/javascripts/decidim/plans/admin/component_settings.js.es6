$(() => {
  const showHideAnswer = () => {
    const val = $("#component_settings_default_state").val();

    const $label = $("label[for='component_settings_default_answer']").parent();
    const $editor = $("[data-tabs-content='global-settings-default_answer-tabs']");

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
