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
      include CarrierWave::MiniMagick

      process :set_content_type_and_size_in_model
      process :validate_dimensions
      process :orientate, if: :image?
      process :strip

      Decidim::Plans.attachment_image_versions.each do |key, process_options|
        version key, if: :image? do
          process process_options
        end
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

      def extension_whitelist
        case model.upload_type
        when :image
          %w(jpg jpeg png)
        else
          Decidim.organization_settings(model).upload_allowed_file_extensions
        end
      end

      # CarrierWave automatically calls this method and validates the content
      # type fo the temp file to match against any of these options.
      def content_type_whitelist
        case model.upload_type
        when :image
          [%r{image/}]
        else
          Decidim.organization_settings(model).upload_allowed_content_types
        end
      end

      protected

      # Flips the image to be in correct orientation based on its Exif
      # orientation metadata.
      def orientate
        manipulate! do |img|
          img.tap(&:auto_orient)
          img = yield(img) if block_given?
          img
        end
      end

      # Strips out all embedded information from the image
      def strip
        return unless image?(self)

        manipulate! do |img|
          img.strip
          img
        end
      end

      # Checks if the file is an image based on the content type. We need this so
      # we only create different versions of the file when it's an image.
      #
      # new_file - The uploaded file.
      #
      # Returns a Boolean.
      def image?(new_file)
        content_type = model.content_type || new_file.content_type
        content_type.to_s.start_with? "image"
      end

      # Copies the content type and file size to the model where this is mounted.
      #
      # Returns nothing.
      def set_content_type_and_size_in_model
        model.content_type = file.content_type if file.content_type
        model.file_size = file.size
      end

      # A simple check to avoid DoS with maliciously crafted images, or just to
      # avoid reckless users that upload gigapixels images.
      #
      # See https://hackerone.com/reports/390
      def validate_dimensions
        return unless image?(self)

        manipulate! do |image|
          raise CarrierWave::IntegrityError, I18n.t("carrierwave.errors.image_too_big") if image.dimensions.any? { |dimension| dimension > max_image_height_or_width }

          image
        end
      end

      def max_image_height_or_width
        8000
      end
    end
  end
end
