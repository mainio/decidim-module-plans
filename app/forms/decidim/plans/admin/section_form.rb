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
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :body, translatable_presence: true, unless: :deleted

        def to_param
          id || "section-id"
        end
      end
    end
  end
end
