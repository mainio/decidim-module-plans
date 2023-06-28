# frozen_string_literal: true

module Decidim
  module Plans
    # In order to control the uploaders related to the plan attachments, we
    # need to take control of the attachment records.
    class Attachment < ::Decidim::Attachment
      self.table_name = :decidim_attachments

      has_one_attached :file
      validates_upload :file, uploader: Decidim::Plans::AttachmentUploader

      before_validation :copy_file_attributes

      attr_writer :upload_type

      def self.translatable_fields_list
        superclass.translatable_fields_list
      end

      def upload_type
        @upload_type || :file
      end

      # The URL to download the "main" version of the file. Only works with
      # images.
      #
      # Returns String.
      def main_url
        return unless photo?

        attached_uploader(:file).path(variant: :main)
      end

      private

      def copy_file_attributes
        return unless file

        self.content_type = file.content_type if file.content_type && content_type.blank?
        self.file_size = file.byte_size if file_size.blank?
      end
    end
  end
end
