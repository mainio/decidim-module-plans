# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the attachments field type.
      class FieldImageAttachmentsForm < Decidim::Plans::ContentData::BaseAttachmentsForm
        attribute :attachments, Array[Plans::ImageAttachmentForm]
      end
    end
  end
end
