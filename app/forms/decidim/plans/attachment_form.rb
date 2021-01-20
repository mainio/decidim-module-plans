# frozen_string_literal: true

module Decidim
  module Plans
    class AttachmentForm < Decidim::Plans::BaseAttachmentForm
      validates :file, passthru: { to: Decidim::Plans::Attachment }, if: ->(form) { form.file.present? }
    end
  end
end
