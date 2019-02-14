# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes Plan Request actions for collaboration between
    # participants on a resource.
    class PlanCollaboratorRequestsController < Decidim::Plans::PlansController
      before_action :retrieve_plan, only: [:request_access, :request_accept, :request_reject]

      def request_access
        enforce_permission_to :request_access, :plan, plan: @plan

        @request_access_form = form(RequestAccessToPlanForm).from_params(params)
        RequestAccessToPlan.call(@request_access_form, current_user) do
          on(:ok) do |_plan|
            flash[:notice] = t("access_requested.success", scope: "decidim.plans.requests")
          end

          on(:invalid) do
            flash[:alert] = t("access_requested.error", scope: "decidim.plans.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
      end

      def request_accept
        enforce_permission_to :edit, :plan, plan: @plan

        @accept_request_form = form(AcceptAccessToPlanForm).from_params(params)
        AcceptAccessToPlan.call(@accept_request_form, current_user) do
          on(:ok) do |requester_user|
            flash[:notice] = t("accepted_request.success", scope: "decidim.plans.requests", user: requester_user.nickname)
          end

          on(:invalid) do
            flash[:alert] = t("accepted_request.error", scope: "decidim.plans.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
      end

      def request_reject
        enforce_permission_to :edit, :plan, plan: @plan

        @reject_request_form = form(RejectAccessToPlanForm).from_params(params)
        RejectAccessToPlan.call(@reject_request_form, current_user) do
          on(:ok) do |requester_user|
            flash[:notice] = t("rejected_request.success", scope: "decidim.plans.requests", user: requester_user.nickname)
          end

          on(:invalid) do
            flash.now[:alert] = t("rejected_request.error", scope: "decidim.plans.requests")
          end
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(@plan).path
      end
    end
  end
end
