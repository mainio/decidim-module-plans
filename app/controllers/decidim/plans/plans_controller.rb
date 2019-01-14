# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes the plan resource so users can view and create them.
    class PlansController < Decidim::Plans::ApplicationController
      helper Decidim::WidgetUrlsHelper
      # helper PlanWizardHelper
      include FormFactory
      include FilterResource
      include Orderable
      include Paginable

      before_action :authenticate_user!, only: [:new, :create, :complete]
      before_action :ensure_is_draft, only: [:compare, :complete, :preview, :publish, :edit_draft, :update_draft, :destroy_draft]
      before_action :set_plan, only: [:show, :edit, :update, :withdraw]
      before_action :edit_form, only: [:edit_draft, :edit]
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
      end

      def new
        enforce_permission_to :create, :plan
      #   @step = :step_1
      #   if plan_draft.present?
      #     redirect_to edit_draft_plan_path(plan_draft, component_id: plan_draft.component.id, question_slug: plan_draft.component.participatory_space.slug)
      #   else
      #     @form = form(PlanWizardCreateStepForm).from_params({})
      #   end
      end

      def create
        enforce_permission_to :create, :plan
      #   @step = :step_1
      #   @form = form(PlanWizardCreateStepForm).from_params(params)

      #   CreatePlan.call(@form, current_user) do
      #     on(:ok) do |plan|
      #       flash[:notice] = I18n.t("plans.create.success", scope: "decidim")

      #       redirect_to Decidim::ResourceLocatorPresenter.new(plan).path + "/compare"
      #     end

      #     on(:invalid) do
      #       flash.now[:alert] = I18n.t("plans.create.error", scope: "decidim")
      #       render :new
      #     end
      #   end
      end

      def compare
        @step = :step_2
        @similar_plans ||= Decidim::Plans::SimilarPlans
                               .for(current_component, @plan)
                               .all

        if @similar_plans.blank?
          flash[:notice] = I18n.t("plans.plans.compare.no_similars_found", scope: "decidim")
          redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path + "/complete"
        end
      end

      def complete
        enforce_permission_to :create, :plan
        @step = :step_3

        @form = form_plan_model

        @form.attachment = form_attachment_new
      end

      def preview
        @step = :step_4
      end

      def publish
        @step = :step_4
        PublishPlan.call(@plan, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("plans.publish.success", scope: "decidim")
            redirect_to plan_path(@plan)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.publish.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit_draft
        @step = :step_3
        enforce_permission_to :edit, :plan, plan: @plan
      end

      def update_draft
        @step = :step_1
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form_plan_params
        UpdatePlan.call(@form, current_user, @plan) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.update_draft.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path + "/preview"
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.update_draft.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def destroy_draft
        enforce_permission_to :edit, :plan, plan: @plan

        DestroyPlan.call(@plan, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("plans.destroy_draft.success", scope: "decidim")
            redirect_to new_plan_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.destroy_draft.error", scope: "decidim")
            render :edit_draft
          end
        end
      end

      def edit
        enforce_permission_to :edit, :plan, plan: @plan
      end

      def update
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form_plan_params
        UpdatePlan.call(@form, current_user, @plan) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(plan).path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("plans.update.error", scope: "decidim")
            render :edit
          end
        end
      end

      def withdraw
        enforce_permission_to :withdraw, :plan, plan: @plan

        WithdrawPlan.call(@plan, current_user) do
          on(:ok) do |_plan|
            flash[:notice] = I18n.t("plans.update.success", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
          end
          on(:invalid) do
            flash[:alert] = I18n.t("plans.update.error", scope: "decidim")
            redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
          end
        end
      end

      private

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

      def plan_draft
        Plan.from_all_author_identities(current_user).not_hidden.where(component: current_component).find_by(published_at: nil)
      end

      def ensure_is_draft
        @plan = Plan.not_hidden.where(component: current_component).find(params[:id])
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path unless @plan.draft?
      end

      def set_plan
        @plan = Plan.published.not_hidden.where(component: current_component).find(params[:id])
      end

      def form_plan_params
        form(PlanForm).from_params(params)
      end

      def form_plan_model
        form(PlanForm).from_model(@plan)
      end

      def form_attachment_new
        form(AttachmentForm).from_params({})
      end

      def edit_form
        form_attachment_model = form(AttachmentForm).from_model(@plan.attachments.first)
        @form = form_plan_model
        @form.attachment = form_attachment_model
        @form
      end
    end
  end
end
