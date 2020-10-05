# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class BudgetsExportsController < Admin::ApplicationController
        def new
          enforce_permission_to :export_budgets, :plans

          @form = form(Admin::PlanExportBudgetsForm).from_model(
            current_component
          )
        end

        def create
          enforce_permission_to :export_budgets, :plans

          @form = form(Admin::PlanExportBudgetsForm).from_params(params)
          Admin::ExportPlansToBudgets.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("budgets_exports.create.success", scope: "decidim.plans.admin", number: projects.length)
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("budgets_exports.create.invalid", scope: "decidim.plans.admin")
              render action: "new"
            end
          end
        end
      end
    end
  end
end
