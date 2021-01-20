# frozen_string_literal: true

module Decidim
  module Plans
    class ImageAttachmentForm < Decidim::Plans::BaseAttachmentForm
      validates :file, passthru: {
        to: Decidim::Plans::Attachment,
        with: { upload_type: :image }
      }, if: ->(form) { form.file.present? }
    end
  end
end
