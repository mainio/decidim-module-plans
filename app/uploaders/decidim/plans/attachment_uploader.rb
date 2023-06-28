# frozen_string_literal: true

module Decidim
  module Plans
    # This class deals with uploading attachments related to a plan.
    # We cannot extend Decidim::AttachmentUploader because we need to redefine
    # some of the methods.
    #
    # Carrierwave does not allow to do this. In case we deleted e.g. versions or
    # processors for redefinitions, they would also disappear from the parent
    # uploader.
    class AttachmentUploader < ::Decidim::ApplicationUploader
      set_variants do
        {
          default: { auto_orient: true, strip: true },
          **Decidim::Plans.attachment_image_versions
        }
      end

      def validable_dimensions
        true
      end

      # This needs to be overridden due to legacy reasons. This extended
      # uploader was added afterwards which would cause the directory to change
      # to "uploads/decidim/PLANS/attachment/...". We want to avoid problems
      # fetching the old files in order to remove the "plans" part of the store
      # directory.
      def store_dir
        default_path = "uploads/decidim/attachment/#{mounted_as}/#{model.id}"

        return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

        default_path
      end

      def extension_allowlist
        case model.upload_type
        when :image
          %w(jpg jpeg png)
        else
          Decidim.organization_settings(model).upload_allowed_file_extensions
        end
      end

      # CarrierWave automatically calls this method and validates the content
      # type fo the temp file to match against any of these options.
      def content_type_allowlist
        case model.upload_type
        when :image
          [%r{image/}]
        else
          Decidim.organization_settings(model).upload_allowed_content_types
        end
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
