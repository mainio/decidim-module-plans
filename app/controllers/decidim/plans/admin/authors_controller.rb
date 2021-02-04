# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to manage plans in a participatory process.
      class AuthorsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        helper_method :plan

        def index
          enforce_permission_to :edit, :plan, plan: plan
        end

        def create
          enforce_permission_to :edit, :plan, plan: plan

          @form = form(AddAuthorToPlanForm).from_params(params, component: current_component)

          unless @form.authors.any?
            flash[:alert] = t("add_authors.no_authors", scope: "decidim.plans.plans")
            return redirect_to plan_authors_path(plan)
          end
        end

        def confirm
          enforce_permission_to :edit, :plan, plan: plan

          @form = form(AddAuthorToPlanForm).from_params(params, component: current_component)

          plan = @plan
          AddAuthorsToPlan.call(@form, @plan, current_user) do
            on(:ok) do
              flash[:success] = t("add_authors.success", scope: "decidim.plans.plans")
              redirect_to plan_authors_path(plan)
            end

            on(:invalid) do
              flash[:alert] = t("add_authors.error", scope: "decidim.plans.plans")
              redirect_to plan_authors_path(plan)
            end
          end
        end

        def destroy
          enforce_permission_to :edit, :plan, plan: plan

          plan = @plan
          author = Decidim::UserBaseEntity.find_by(id: params[:id])
          RemoveAuthorFromPlan.call(plan, author) do
            on(:ok) do
              flash[:success] = t("remove_author.success", scope: "decidim.plans.plans")
              redirect_to plan_authors_path(plan)
            end

            on(:invalid) do
              flash[:alert] = t("remove_author.error", scope: "decidim.plans.plans")
              redirect_to plan_authors_path(plan)
            end
          end
        end

        private

        def plan
          @plan ||= Plan.where(component: current_component).find(params[:plan_id])
        end
      end
    end
  end
end
