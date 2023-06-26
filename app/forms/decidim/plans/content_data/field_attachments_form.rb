# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the attachments field type.
      class FieldAttachmentsForm < Decidim::Plans::ContentData::BaseAttachmentsForm
        attribute :attachments, Array[Plans::AttachmentForm]
      end
    end
  end
end
