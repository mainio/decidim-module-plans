# frozen_string_literal: true

module Decidim
  module Plans
    # In order to control the uploaders related to the plan attachments, we
    # need to take control of the attachment records.
    class Attachment < ::Decidim::Attachment
      self.table_name = :decidim_attachments

      mount_uploader :file, Decidim::Plans::AttachmentUploader

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

        file.main.url
      end
    end
  end
end
