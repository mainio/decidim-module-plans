# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to export a collection of
      # plans into the budgeting projects component.
      class PlanExportBudgetsForm < Decidim::Form
        mimic :budgets_export

        attribute :scope_id, Integer
        attribute :target_component_id, Integer
        attribute :target_details, Array[PlanExportBudgetsTargetDetailsForm]
        attribute :default_budget_amount, Integer
        attribute :export_all_closed_plans, Boolean

        validates :target_component_id, :target_component, :current_component, presence: true
        validates :export_all_closed_plans, allow_nil: false, acceptance: true
        validates :default_budget_amount, presence: true, numericality: { greater_than: 0 }

        def map_model(model)
          self.target_details = components_for(model.participatory_space).map do |component|
            PlanExportBudgetsTargetDetailsForm.from_model(component)
          end
        end

        def scope
          Decidim::Scope.find_by(id: scope_id)
        end

        def target_component
          @target_component ||= target_components.find_by(id: target_component_id)
        end

        def target_components
          @target_components ||= components_for(current_participatory_space)
        end

        def components_for(participatory_space)
          participatory_space.components.where(manifest_name: :budgets)
        end

        def target_components_collection
          target_components.map do |component|
            [component.name[I18n.locale.to_s], component.id]
          end
        end

        def details
          @details ||= target_details.detect do |sub|
            sub.component_id == target_component_id
          end
        end
      end
    end
  end
end
