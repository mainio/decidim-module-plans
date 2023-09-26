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
      helper Plans::PlanLayoutHelper
      include AttachedProposalsHelper
      include FormFactory
      include FilterResource
      include Decidim::Orderable
      include Plans::Orderable
      include Paginable
      include UserPublicityHelper

      helper_method :trigger_feedback?, :user_public?

      before_action :authenticate_user!, only: [:create, :edit, :update, :withdraw, :preview, :publish, :close, :destroy, :add_authors, :add_authors_confirm, :disjoin]
      before_action :check_draft, only: [:new]
      before_action :retrieve_plan, only: [:show, :edit, :update, :withdraw, :preview, :publish, :close, :destroy, :add_authors, :add_authors_confirm, :disjoin]
      before_action :ensure_published!, only: [:show, :withdraw, :add_authors, :add_authors_confirm]

      def index
        enforce_permission_to :read, :plans

        base_query = search.result.distinct
        @plans = base_query
        @geocoded_plans = base_query.geocoded_data_for(current_component)

        # The random ordering does not work with `.distinct` so we need to wrap
        # it in a subquery that is ordered randomly.
        @plans = Plan.where(id: @plans)
        @plans = paginate(@plans)
        @plans = reorder(@plans)
      end

      def show
        enforce_permission_to :read, :plan, plan: @plan

        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
        @request_access_form = form(RequestAccessToPlanForm).from_params({})
        @accept_request_form = form(AcceptAccessToPlanForm).from_params({})
        @reject_request_form = form(RejectAccessToPlanForm).from_params({})
      end

      def new
        if component_settings.form_preview_allowed? && (!user_signed_in? || !user_public?)
          @preview = true
        else
          enforce_permission_to :create, :plan
        end

        @form = form(PlanForm).from_model(Plan.new(component: current_component))
      end

      def create
        enforce_permission_to :create, :plan

        @form = form(PlanForm).from_params(params, component: current_component)
        show_preview = params[:save_type] != "save"

        CreatePlan.call(@form, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.create.success", scope: "decidim")
            if show_preview
              redirect_to routes_proxy.preview_plan_path(plan)
            else
              redirect_to routes_proxy.edit_plan_path(plan)
            end
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

        @form = form(PlanForm).from_params(params, component: current_component)
        show_preview = params[:save_type] != "save"

        UpdatePlan.call(@form, current_user, @plan) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("plans.plans.update.success", scope: "decidim")

            return redirect_to Decidim::ResourceLocatorPresenter.new(plan).path if plan.published?

            if show_preview
              redirect_to routes_proxy.preview_plan_path(plan)
            else
              redirect_to routes_proxy.edit_plan_path(plan)
            end
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
            redirect_to routes_proxy.new_plan_path
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
        enforce_permission_to :publish, :plan, plan: @plan

        PublishPlan.call(@plan, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("publish.success", scope: "decidim.plans.plans.plan")
            session["decidim-plans.published"] = true
            redirect_to routes_proxy.plan_path(plan)
          end

          on(:invalid) do
            flash.now[:alert] = t("publish.error", scope: "decidim.plans.plans.plan")
            redirect_to routes_proxy.plan_path(@plan)
          end
        end
      end

      def close
        enforce_permission_to :close, :plan, plan: @plan

        ClosePlan.call(@plan, current_user) do
          on(:ok) do |plan|
            flash[:notice] = I18n.t("close.success", scope: "decidim.plans.plans.plan")
            redirect_to routes_proxy.plan_path(plan)
          end

          on(:invalid) do
            flash.now[:alert] = t("close.error", scope: "decidim.plans.plans.plan")
            redirect_to routes_proxy.plan_path(@plan)
          end
        end
      end

      def add_authors
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(AddAuthorToPlanForm).from_params(params, component: current_component)

        unless @form.authors.any?
          flash[:alert] = t("add_authors.no_authors", scope: "decidim.plans.plans")
          redirect_to routes_proxy.plan_path(@plan)
        end
      end

      def add_authors_confirm
        enforce_permission_to :edit, :plan, plan: @plan

        @form = form(AddAuthorToPlanForm).from_params(params, component: current_component)

        AddAuthorsToPlan.call(@form, @plan, current_user) do
          on(:ok) do |plan|
            flash[:success] = t("add_authors.success", scope: "decidim.plans.plans")
            redirect_to routes_proxy.plan_path(plan)
          end

          on(:invalid) do
            flash[:alert] = t("add_authors.error", scope: "decidim.plans.plans")
            redirect_to routes_proxy.plan_path(@plan)
          end
        end
      end

      def disjoin
        enforce_permission_to :disjoin, :plan, plan: @plan

        DisjoinPlan.call(@plan, current_user) do
          on(:ok) do |plan|
            flash[:success] = t("disjoin.success", scope: "decidim.plans.plans")
            redirect_to routes_proxy.plan_path(plan)
          end

          on(:invalid) do
            flash[:alert] = t("disjoin.error", scope: "decidim.plans.plans")
            redirect_to routes_proxy.plan_path(@plan)
          end
        end
      end

      private

      def trigger_feedback?
        @trigger_feedback ||= session.delete("decidim-plans.published")
      end

      def layout
        case action_name
        when "new", "create", "edit", "update", "preview", "add_authors"
          "decidim/plans/participatory_space_plain"
        else
          super
        end
      end

      def check_draft
        redirect_to routes_proxy.edit_plan_path(plan_draft) if plan_draft.present?
      end

      def plan_draft
        return unless user_signed_in?

        @plan_draft ||= Plan.drafts.from_all_author_identities(current_user).not_hidden.find_by(component: current_component)
      end

      def retrieve_plan
        @plan ||= Plan.where(component: current_component).find(params[:id])
      end

      def ensure_published!
        return unless @plan
        return if @plan.published?

        raise ActionController::RoutingError, "Not Found" unless @plan.editable_by?(current_user)

        redirect_to routes_proxy.preview_plan_path(@plan)
      end

      def search_collection
        Plan.where(component: current_component).published.not_hidden.with_availability(params[:filter].try(:[], :with_availability))
      end

      def default_filter_params
        {
          search_text: "",
          with_any_origin: default_filter_origin_params,
          with_any_category: "",
          with_any_state: "",
          with_any_scope: nil,
          with_any_tag: [],
          related_to: "",
          activity: "",
          section: default_section_filter_params
        }
      end

      def default_section_filter_params
        Decidim::Plans::Section.where(component: current_component).to_h do |section|
          # manifest = section.section_type_manifest
          control = section.section_type_manifest.content_control_class.new

          [section.id, control.search_params_for(section)]
        end
      end

      def default_filter_origin_params
        filter_origin_params = %w(participants official)
        filter_origin_params << "user_group" if current_organization.user_groups_enabled?
        filter_origin_params
      end

      def routes_proxy
        @routes_proxy ||= EngineRouter.main_proxy(current_component)
      end
    end
  end
end
