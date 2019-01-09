# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to manage plans in a participatory process.
      class PlansController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        helper Plans::ApplicationHelper
        helper_method :plans, :query, :form_presenter

        def new
          enforce_permission_to :create, :plans
          @form = form(Admin::PlanForm).from_model(Plan.new(component: current_component))
          @form.attachment = form(AttachmentForm).from_params({})
        end

        def create
          enforce_permission_to :create, :plan
          @form = form(Admin::PlanForm).from_params(params)

          Admin::CreatePlan.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("plans.create.success", scope: "decidim")
              redirect_to plans_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("plans.create.invalid", scope: "decidim")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :edit, :plan, plan: plan
          @form = form(Admin::PlanForm).from_model(plan)
          @form.attachment = form(AttachmentForm).from_params({})
        end

        def update
          enforce_permission_to :edit, :plan, plan: plan

          @form = form(Admin::PlanForm).from_params(params)
          Admin::UpdatePlan.call(@form, @plan) do
            on(:ok) do
              flash[:notice] = I18n.t("plans.update.success", scope: "decidim")
              redirect_to plans_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("plans.update.error", scope: "decidim")
              render :edit
            end
          end
        end

        private

        def query
          @query ||= Plan.where(component: current_component).published.ransack(params[:q])
        end

        def plans
          @plans ||= query.result.page(params[:page]).per(15)
        end

        def plan
          @plan ||= Plan.where(component: current_component).find(params[:id])
        end

        def form_presenter
          @form_presenter ||= present(@form, presenter_class: Decidim::Plans::PlanPresenter)
        end
      end
    end
  end
end
