# frozen_string_literal: true

module Decidim
  module Plans
    module AttachmentsHelper
      def tabs_id_for_attachment(attachment)
        "attachment_#{attachment.to_param}"
      end

      def blank_attachment
        @blank_attachment ||= Plans::AttachmentForm.new
      end

      # A modified version of the Decidim's own form builder `upload` method
      # which is buggy for multiple file fields.
      #
      # See:
      # Decidim::FormBuilder#upload
      #
      # form         - The form object for which to create the field.
      # attribute    - The String/Symbol name of the attribute to build the
      #                field.
      def upload_field(form, attribute)
        file = form.object.send attribute
        required = file.nil? || !file.attached?

        label_content = form.label_for(attribute)
        label_content += required_tag if required
        template = ""
        template += form.label(attribute, label_content)
        template += form.file_field attribute, label: false
        file_path = form.object.attached_uploader(attribute).path
        if form.send(:file_is_image?, file)
          template += if file.present?
                        content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                      else
                        content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                      end
          template += link_to image_tag(file_path), file_path, target: "_blank", rel: "noopener"
        elsif form.send(:file_is_present?, file)
          template += label_tag I18n.t("current_file", scope: "decidim.forms")
          template += link_to file.filename.to_s, file_path, target: "_blank", rel: "noopener"
        end

        template.html_safe
      end

      def required_tag
        content_tag(
          :abbr,
          "*",
          title: I18n.t("required", scope: "forms"),
          data: { tooltip: true, disable_hover: false }, "aria-haspopup": true,
          class: "label-required"
        ).html_safe
      end
    end
  end
end
