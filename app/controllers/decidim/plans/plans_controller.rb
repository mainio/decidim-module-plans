# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes the plan resource so users can view and create them.
    class PlansController < Decidim::Plans::ApplicationController
      helper Decidim::WidgetUrlsHelper
      # helper PlanWizardHelper
      helper TooltipHelper
      include FormFactory
      include FilterResource
      include Orderable
      include Paginable

      before_action :authenticate_user!, only: [:new, :create, :complete]
      before_action :retrieve_plan, only: [:show, :edit, :update, :withdraw, :publish]

      def index
        @plans = search
                 .results
                 .includes(:category)
                 .includes(:scope)

        @plans = paginate(@plans)
        @plans = reorder(@plans)
      end

      def show
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
        @request_access_form = form(RequestAccessToPlanForm).from_params({})
        @accept_request_form = form(AcceptAccessToPlanForm).from_params({})
        @reject_request_form = form(RejectAccessToPlanForm).from_params({})
      end

      def new
        enforce_permission_to :create, :plan
        @step = :step_1

        @form = form(PlanForm).from_params(
          attachment: form(AttachmentForm).from_params({})
        )
      end

      def compare
        @step = :step_2
        @similar_plans ||= Decidim::Plans::SimilarPlans
                           .for(current_component, params[:plan])
                           .all
        @form = form(PlanForm).from_params(params)

        if @similar_plans.blank?
          flash[:notice] = I18n.t("plans.plans.compare.no_similars_found", scope: "decidim")
          redirect_to complete_plans_path(plan: { title: @form.title, body: @form.body })
        end
      end

      def complete
        enforce_permission_to :create, :plan
        @step = :step_3
        if params[:plan].present?
          params[:plan][:attachment] = form(AttachmentForm).from_params({})
          @form = form(PlanForm).from_params(params)
        else
          @form = form(PlanForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end
      end

      def create
        enforce_permission_to :create, :plan
        @step = :step_3
        @form = form(PlanForm).from_params(params)

        CreatePlan.call(@form, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.create.success", scope: "decidim")

            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.plans.create.error", scope: "decidim")
            render :complete
          end
        end
      end

      def edit
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(PlanForm).from_model(@plan)
      end

      def update
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(PlanForm).from_params(params)
        UpdatePlan.call(@form, current_user, @plan) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.plans.update.error", scope: "decidim")
            render :edit
          end
        end
      end

      def withdraw
        WithdrawPlan.call(@plan, current_user) do
          on(:ok) do
            flash[:notice] = t("withdraw.success", scope: "decidim.plans.plans.plan")
          end

          on(:invalid) do
            flash.now[:alert] = t("withdraw.error", scope: "decidim.plans.plans.plan")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
      end

      def publish
        PublishPlan.call(@plan, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("publish.success", scope: "decidim.plans.plans.plan")
            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path
          end

          on(:invalid) do
            flash.now[:alert] = t("publish.error", scope: "decidim.plans.plans.plan")
            redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
          end
        end
      end

      private

      def retrieve_plan
        @plan = Plan.where(component: current_component).find(params[:id])
      end

      def search_klass
        PlanSearch
      end

      def default_filter_params
        {
          search_text: "",
          origin: "all",
          activity: "",
          category_id: "",
          state: "except_rejected",
          scope_id: nil,
          related_to: ""
        }
      end
    end
  end
end
