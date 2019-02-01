# frozen_string_literal: true

module Decidim
  module Plans
    class AttachmentForm < Decidim::Form
      attribute :title, String
      attribute :file
      attribute :weight, Integer
      attribute :deleted, Boolean, default: false

      mimic :attachment

      validates :title, presence: true, if: ->(form) { form.file.present? || form.id.present? }

      def to_param
        id || "attachment-id"
      end
    end
  end
end
