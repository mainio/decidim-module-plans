# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to answer plans in a participatory process.
      class PlanAnswersController < Admin::ApplicationController
        helper_method :plan

        def edit
          enforce_permission_to :create, :plan_answer
          @form = form(Admin::PlanAnswerForm).from_model(plan)
        end

        def update
          enforce_permission_to :create, :plan_answer
          @form = form(Admin::PlanAnswerForm).from_params(params)

          Admin::AnswerPlan.call(@form, plan) do
            on(:ok) do
              flash[:notice] = I18n.t("plans.answer.success", scope: "decidim.plans.admin")
              redirect_to plans_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("plans.answer.invalid", scope: "decidim.plans.admin")
              render action: "edit"
            end
          end
        end

        private

        def plan
          @plan ||= Plan.where(component: current_component).find(params[:id])
        end
      end
    end
  end
end
