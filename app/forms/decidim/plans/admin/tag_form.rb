# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class TagForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        mimic :tag

        alias organization current_organization

        translatable_attribute :name, String
        attribute :back_to_plan, Boolean

        validates :name, translatable_presence: true
      end
    end
  end
end
