# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the attachments field type.
      class FieldAttachmentsForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_attachments_field

        attribute :attachments, Array[Plans::AttachmentForm]

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

        def valid?(options = {})
          base_valid = super

          attachments.all? { |at| at.valid?(options) } && base_valid
        end
      end
    end
  end
end
