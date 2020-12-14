# frozen_string_literal: true

module Decidim
  module Plans
    # This cell renders attachments for a record.
    class AttachmentsCell < Decidim::ViewModel
      include ActiveSupport::NumberHelper
      include ActionView::Helpers::SanitizeHelper
      include Cell::ViewModel::Partial
      include Decidim::LayoutHelper # For the icon helper
      include Decidim::TranslatableAttributes

      def show
        return unless model.attachments.any?

        render
      end

      def display_documents
        return unless documents.any?

        render :documents
      end

      def display_photos
        return unless photos.any?

        render :photos
      end

      private

      def documents
        model.documents
      end

      def documents_without_collection
        @documents_without_collection ||= documents.reject(&:attachment_collection_id?)
      end

      def document_collections
        @document_collections ||= documents.select(
          &:attachment_collection_id?
        ).group_by(&:attachment_collection).sort_by { |c, d| c.weight }
      end

      def photos
        model.photos
      end

      # Renders the attachment's title.
      # Checks if the attachment's title is translated or not and use
      # the correct render method.
      #
      # attachment - An Attachment object
      #
      # Returns String.
      def attachment_title(attachment)
        attachment.title.is_a?(Hash) ? translated_attribute(attachment.title) : attachment.title
      end
    end
  end
end
