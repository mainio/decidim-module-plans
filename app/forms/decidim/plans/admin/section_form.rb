# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class SectionForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        mimic :section

        translatable_attribute :body, String
        translatable_attribute :help, String
        attribute :mandatory, Boolean, default: false
        attribute :answer_length, Integer, default: 0
        attribute :section_type, String
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :body, translatable_presence: true, unless: :deleted
        validates :answer_length, numericality: {
          greater_than_or_equal_to: 0,
          only_integer: true
        }

        def to_param
          return id if id.present?

          "section-id"
        end
      end
    end
  end
end
