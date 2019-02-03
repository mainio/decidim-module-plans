# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes the plan resource so users can view and create them.
    class PlansController < Decidim::Plans::ApplicationController
      helper Decidim::WidgetUrlsHelper
      helper UserGroupHelper
      helper TooltipHelper
      helper Plans::AttachmentsHelper
      helper Plans::RemainingCharactersHelper
      include AttachedProposalsHelper
      include FormFactory
      include FilterResource
      include Orderable
      include Paginable

      helper_method :attached_proposals_picker_field

      before_action :authenticate_user!, only: [:new, :create, :edit, :update, :withdraw, :preview, :publish, :destroy]
      before_action :check_draft, only: [:new]
      before_action :retrieve_plan, only: [:show, :edit, :update, :withdraw, :preview, :publish, :destroy]
      before_action :ensure_published!, only: [:show, :withdraw]

      def index
        @plans = search
                 .results
                 .published
                 .not_hidden
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

        @form = form(PlanForm).from_model(Plan.new(component: current_component))
      end

      def create
        enforce_permission_to :create, :plan

        @form = form(PlanForm).from_params(params, compontent: current_component)

        CreatePlan.call(@form, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.create.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path + "/preview"
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.plans.create.error", scope: "decidim")
            render :new
          end
        end
      end

      def edit
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(PlanForm).from_model(@plan)
      end

      def update
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(PlanForm).from_params(params, compontent: current_component)
        UpdatePlan.call(@form, current_user, @plan) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.update.success", scope: "decidim")

            return redirect_to Decidim::ResourceLocatorPresenter.new(plan).path if plan.published?

            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path + "/preview"
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.plans.update.error", scope: "decidim")
            render :edit
          end
        end
      end

      def destroy
        enforce_permission_to :edit, :plan, plan: @plan

        # Form needed in case destroing fails
        @form = form(PlanForm).from_model(@plan)

        DestroyPlan.call(@plan, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("plans.plans.destroy.success", scope: "decidim")
            redirect_to new_plan_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.plans.destroy.error", scope: "decidim")
            render :edit
          end
        end
      end

      def withdraw
        raise ActionController::RoutingError, "Not Found" if @plan.withdrawn?
        enforce_permission_to :withdraw, :plan, plan: @plan

        WithdrawPlan.call(@plan, current_user) do
          on(:ok) do
            flash[:notice] = t("withdraw.success", scope: "decidim.plans.plans")
          end

          on(:invalid) do
            flash.now[:alert] = t("withdraw.error", scope: "decidim.plans.plans")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
      end

      def preview; end

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

      def check_draft
        redirect_to edit_plan_path(plan_draft) if plan_draft.present?
      end

      def plan_draft
        Plan.drafts.from_all_author_identities(current_user).not_hidden.where(component: current_component)
      end

      def retrieve_plan
        @plan = Plan.where(component: current_component).find(params[:id])
      end

      def ensure_published!
        return unless @plan
        return if @plan.published?

        raise ActionController::RoutingError, "Not Found" unless @plan.editable_by?(current_user)

        redirect_to preview_plan_path(@plan)
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

      def context_params
        {
          component: current_component,
          organization: current_organization
        }
      end
    end
  end
end
