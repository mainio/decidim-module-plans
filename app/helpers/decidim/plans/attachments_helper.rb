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
      # options      - A Hash with options to build the field.
      #              * optional: Whether the file can be optional or not.
      def upload_field(form, attribute, options = {})
        options[:optional] = options[:optional].nil? ? true : options[:optional]

        file = form.object.send attribute
        template = ""
        template += label(attribute, form.label_for(attribute) + form.send(:required_for_attribute, attribute))
        template += form.file_field attribute, label: false

        if form.send(:file_is_image?, file)
          template += if file.present?
                        content_tag :label, I18n.t("current_image", scope: "decidim.forms")
                      else
                        content_tag :label, I18n.t("default_image", scope: "decidim.forms")
                      end
          template += link_to image_tag(file.url), file.url, target: "_blank"
        elsif form.send(:file_is_present?, file)
          template += label_tag I18n.t("current_file", scope: "decidim.forms")
          template += link_to file.file.filename, file.url, target: "_blank"
        end

        template.html_safe
      end
    end
  end
end
