# frozen_string_literal: true

module Decidim
  module Plans
    class AttachmentForm < Decidim::Plans::BaseAttachmentForm
      validates :file, passthru: {
        to: Decidim::Plans::Attachment,
        with: {
          attached_to: lambda do |form|
            form.current_organization
          end
        }
      }, if: ->(form) { form.file.present? }
    end
  end
end
