# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the attachments field type.
      class BaseAttachmentsForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_attachments_field

        attribute :attachments, Array

        validate :attachments_presence

        def map_model(model)
          super

          ids = model.body["attachment_ids"]
          return unless ids.is_a?(Array)

          self.attachments = ids.map do |id|
            Decidim::Attachment.find_by(id: id)
          end
        end

        def body
          { attachment_ids: attachments.map(&:id) }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          self.attachment_ids = data["attachment_ids"] || data[:attachment_ids]
        end

        def valid?(_options = {})
          # Calling .valid? on the attachment form would clear the errors that
          # were possibly added by the section control.
          add_attachments.none? { |at| at.errors.any? }
        end

        private

        def attachments_presence
          return unless form.mandatory
          return if attachments.present? || add_attachments.present?

          errors.add(:attachments, :invalid)
        end
      end
    end
  end
end
