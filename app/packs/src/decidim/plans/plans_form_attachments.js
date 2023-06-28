((exports) => {
  const $ = exports.$; // eslint-disable-line id-length

  const openModalFor = ($container, $section) => {
    const modalId = $container.data("modal-id");
    const $modal = $(`#${modalId}`);
    const $fields = $(".attachment-fields", $section);
    $fields.data("section", $section);

    $(".attachment-fields-wrapper", $modal).append($fields);
    $modal.foundation("open");
  };

  const bindAttachmentModal = ($container) => {
    const modalId = $container.data("modal-id")
    const $modal = $(`#${modalId}`);
    const fileMissing = ($file) => $file.get(0).files.length === 0;
    const attachmentSuccess = ($fields) => {
      const $file = $("input[type='file']", $fields);
      const filePresent = $fields.data("file-present");
      if (fileMissing($file) && !filePresent) {
        return false;
      }

      const $text = $("input[type='text']", $fields);
      if ($.trim($text.val()).length < 1) {
        return false;
      }

      return true;
    };
    const cancelAttachment = ($reveal) => {
      const $fields = $(".attachment-fields", $reveal);
      const $file = $("input[type='file']", $fields);
      const $text = $("input[type='text']", $fields);
      const $remove = $("input[name$='[deleted]']", $fields);

      $(".form-error-general", $reveal).removeClass("is-visible");

      const originalFiles = $file.data("original-value");
      if (originalFiles.length > 0) {
        $file.get(0).files = originalFiles;
      } else {
        $file.replaceWith($file.val("").clone(true));
      }

      $text.val($text.data("original-value"));
      $remove.attr("value", $remove.data("original-value"));

      if (!attachmentSuccess($fields)) {
        // In case of an error, remove the file section from the form
        const $section = $fields.data("section");
        $(".remove-field", $section).trigger("click");

        // Remove the fields from the modal
        $fields.remove();
      }
    };

    // The attachment fields need to be inside the form when it is submitted but
    // the reveal is displayed outside of the form. Therefore, we move the
    // fields to the reveal when it is opened and back to the form when it is
    // closed.
    $modal.on("open.zf.reveal", (ev) => {
      const $reveal = $(ev.target);
      const $fields = $(".attachment-fields", $reveal);
      const $file = $("input[type='file']", $fields);
      const $text = $("input[type='text']", $fields);
      const $remove = $("input[name$='[deleted]']", $fields);

      $file.data("original-value", $file.get(0).files);
      $text.data("original-value", $text.val());
      $remove.data("original-value", $remove.val()).removeAttr("value");
    });
    $modal.on("closed.zf.reveal", (ev) => {
      const $reveal = $(ev.target);
      const $fields = $(".attachment-fields", $reveal);

      if ($fields.length < 1) {
        // The fields were already removed
        return;
      }

      const $section = $fields.data("section");

      if (attachmentSuccess($fields)) {
        const $text = $("input[type='text']", $fields);
        const $file = $("input[type='file']", $fields);
        const $title = $(".attachment-title", $section);

        let title = $text.val();
        let fileName = $file.val();
        if (fileName && fileName.length > 0) {
          // Remove the browser added path from the filename. Splits the string
          // with directory separator characters and gets the last part.
          fileName = fileName.split(/(\\|\/)/g).pop();
        }
        if (!fileName || fileName.length < 1) {
          // If the file is not updated, fetch the original file name if it is
          // available.
          fileName = $title.data("original-filename");
        }
        if (fileName && fileName.length > 0) {
          title = `${title} (${fileName})`;
        }

        $title.text(title);
      } else {
        cancelAttachment($reveal);
      }

      $section.append($fields);
    });

    $(".add-attachment", $modal).on("click", (ev) => {
      // Sometimes the form is submitted in case the event is not prevented.
      ev.preventDefault();

      const $reveal = $(ev.target).closest(".reveal");
      const $fields = $(".attachment-fields", $reveal);
      const $file = $("input[type='file']", $fields);
      const $text = $("input[type='text']", $fields);
      const $remove = $("input[name$='[deleted]']", $fields);
      const filePresent = $fields.data("file-present");

      $(".form-error-general", $reveal).removeClass("is-visible");

      let success = true;
      if (fileMissing($file) && !filePresent) {
        success = false;
        $(".form-error-general", $file.closest(".field")).addClass("is-visible");
      }
      if ($.trim($text.val()).length < 1) {
        success = false;
        $(".form-error-general", $text.closest(".field")).addClass("is-visible");
      }

      if (success) {
        $remove.attr("value", "false");
        $reveal.foundation("close");
      }
    });

    $(".cancel-attachment", $modal).on("click", (ev) => {
      // Prevent the form submission or validation.
      ev.preventDefault();

      const $reveal = $(ev.target).closest(".reveal");
      cancelAttachment($reveal);
    });
  };

  const initSection = ($elem, $field) => {
    $(".edit-attachment", $field).on("click", (ev) => {
      ev.preventDefault();
      openModalFor($elem, $field);
    });
  };

  $.fn.attachmentfield = function() {
    $(this).each((_i, el) => {
      const $elem = $(el);
      let id = $elem.attr("id");
      if (!id || id.length < 1) {
        id = `attachments-${Math.random().toString(16).slice(2)}`;
        $elem.attr("id", id);
      }
      bindAttachmentModal($elem);

      // Bind to multifields
      $elem.on("add-multifield.decidim-plans", (_ev, $field) => {
        initSection($elem, $field);
        openModalFor($elem, $field);
      });

      // Bind the edit buttons to open the modal
      $(".attached-file", $elem).each((_j, fieldEl) => {
        initSection($elem, $(fieldEl));
      });
    });
  }
})(window);
