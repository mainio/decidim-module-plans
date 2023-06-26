# frozen_string_literal: true

module Decidim
  module Plans
    class BaseAttachmentForm < Decidim::Form
      include Decidim::TranslatableAttributes

      attribute :title, String
      attribute :file
      attribute :weight, Integer
      attribute :deleted, Boolean, default: false

      mimic :attachment

      validates :title, presence: true, if: ->(form) { form.file.present? || form.id.present? }

      def map_model(model)
        self.title = translated_attribute(model.title)
      end

      def to_param
        return id if id.present?

        "attachment-id"
      end
    end
  end
end
