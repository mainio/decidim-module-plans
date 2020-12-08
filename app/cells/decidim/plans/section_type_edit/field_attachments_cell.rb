# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldAttachmentsCell < Decidim::Plans::SectionEditCell
        include Cell::ViewModel::Partial
        include Decidim::Plans::AttachmentsHelper

        private

        def legend_text
          translated_attribute(section.body)
        end

        def blank_attachment
          @blank_attachment ||= Plans::AttachmentForm.new
        end

        def existing_attachments
          form.object.attachments
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
