# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when public users want to create a plan.
    class PlanWizardCreateStepForm < Decidim::Form
      include TranslatableAttributes
      mimic :plan

      translatable_attribute :title, String
      attribute :user_group_id, Integer

      validates :title, translatable_presence: true

      alias component current_component

      def map_model(model)
        self.user_group_id = model.user_groups.first&.id
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end
    end
  end
end
