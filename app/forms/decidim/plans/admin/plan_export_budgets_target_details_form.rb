# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to export a collection of
      # plans into the budgeting projects component and map those to a specific
      # component and budget.
      class PlanExportBudgetsTargetDetailsForm < Decidim::Form
        mimic :budgets_export_target

        attribute :component_id, Integer
        attribute :budget_id, Integer

        validates :component_id, :budget_id, presence: true

        def map_model(component)
          self.component_id = component.id
        end

        def target_budget
          @target_budget ||= target_budgets.find_by(id: budget_id)
        end

        def target_budgets
          @target_budgets ||= Decidim::Budgets::Budget.where(
            component: target_component
          ).order(weight: :asc)
        end

        def target_budgets_collection
          target_budgets.map do |budget|
            [budget.title[I18n.locale.to_s], budget.id]
          end
        end

        def target_component
          @target_component ||= Decidim::Component.find_by(id: component_id)
        end
      end
    end
  end
end
