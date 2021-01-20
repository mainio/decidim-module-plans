# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the attachments field type.
      class BaseAttachmentsForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_attachments_field

        validates :attachments, presence: true, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          ids = model.body["attachment_ids"]
          return unless ids.is_a?(Array)

          self.attachments = ids.map do |id|
            Plans::AttachmentForm.from_model(
              Decidim::Attachment.find_by(id: id)
            )
          end
        end

        def body
          { attachment_ids: attachments.map(&:id) }
        end

        def valid?(_options = {})
          # Calling .valid? on the attachment form would clear the errors that
          # were possibly added by the section control.
          attachments.none? { |at| at.errors.any? }
        end
      end
    end
  end
end
