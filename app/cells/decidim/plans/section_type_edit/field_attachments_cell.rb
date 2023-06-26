# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldAttachmentsCell < Decidim::Plans::SectionEditCell
        include Cell::ViewModel::Partial
        include ERB::Util
        include Decidim::Plans::AttachmentsHelper

        private

        def field_id
          @field_id ||= "attachments_#{SecureRandom.uuid}"
        end

        def help_i18n_scope
          case section.section_type
          when "field_image_attachments"
            "decidim.forms.file_help.image"
          else
            "decidim.forms.file_help.file"
          end
        end

        def legend_text
          translated_attribute(section.body)
        end

        def blank_attachment
          @blank_attachment ||= begin
            case section.section_type
            when "field_image_attachments"
              Plans::ImageAttachmentForm.new
            else
              Plans::AttachmentForm.new
            end
          end
        end

        def existing_attachments
          form.object.attachments
        end

        def file_is_present?(form)
          file = form.file
          return false unless file
          return false unless file.respond_to?(:url)

          file.url.present?
        end

        def attachment_title_for(attachment)
          title = attachment.title
          title = "#{title} (#{file_name_for(attachment.file)})" if attachment.file && attachment.file.try(:url).present?

          title
        end

        def file_name_for(file)
          case file
          when ActionDispatch::Http::UploadedFile
            file.original_filename
          else
            # Carrierwave SanitizedFile
            file.file.filename
          end
        end

        def multi_attachment?
          input_type == "multi"
        end

        def input_type
          return "single" unless settings["attachments_input_type"]

          settings["attachments_input_type"]
        end
      end
    end
  end
end
