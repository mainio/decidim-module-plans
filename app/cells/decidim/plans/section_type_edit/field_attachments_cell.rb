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

        def existing_attachments
          form.object.attachments
        end

        def multi_attachment?
          input_type == "multi"
        end

        def extension_allowlist
          @extension_allowlist ||=
            case section.section_type
            when "field_image_attachments"
              Decidim::OrganizationSettings.for(section.organization).upload_allowed_file_extensions_image
            else
              Decidim.organization_settings(section.organization).upload_allowed_file_extensions
            end
        end

        def input_type
          return "single" unless settings["attachments_input_type"]

          settings["attachments_input_type"]
        end
      end
    end
  end
end
