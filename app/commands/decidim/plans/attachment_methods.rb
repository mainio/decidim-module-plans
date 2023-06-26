# frozen_string_literal: true

module Decidim
  module Plans
    # A module with all the attachment methods for plan commands.
    module AttachmentMethods
      include NestedUpdater

      private

      def prepare_attachments
        @form.attachments.each do |atform|
          next if atform.file.present? || atform.id.blank?

          attachment = @plan.attachments.find_by(id: atform.id)
          atform.file = attachment.file if attachment
        end
      end

      def mark_attachment_reattachment
        if @form.invalid? || @form.errors.any?
          @form.attachments.each do |at|
            at.errors.add(:file, :needs_to_be_reattached) if at.present? && at.id.blank?
          end
        end
      end

      def attachments_invalid?
        @form.attachments.each do |atform|
          next if atform.deleted?

          attachment = Attachment.new(attachment_params(atform))

          next if attachment.valid? || !attachment.errors.has_key?(:file)

          atform.errors.add :file, attachment.errors[:file]
        end

        @form.attachments.any? { |at| at.errors.any? }
      end

      def attachments_present?
        attachments_allowed? && @form.attachments.any? do |at|
          at.title.present? || at.file.present? || at.id.present?
        end
      end

      def update_attachments
        @form.attachments.each do |attachment|
          update_nested_model(
            attachment,
            attachment_params(attachment),
            @plan.attachments
          )
        end
      end

      def attachments_allowed?
        @form.current_component.settings.attachments_allowed?
      end

      def process_attachments?
        attachments_allowed? && attachments_present?
      end

      def attachment_params(form)
        params = {
          weight: form.weight,
          title: { I18n.locale => form.title },
          attached_to: @attached_to
        }
        params[:file] = form.file if form.file.present?

        params
      end
    end
  end
end
