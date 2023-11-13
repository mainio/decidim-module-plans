# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders a plans picker.
    class PlansPickerCell < Decidim::ViewModel
      include Decidim::ComponentPathHelper

      delegate :current_user, to: :controller

      MAX_PLANS = 1000

      def show
        if params.keys.include?("q")
          render :plans
        else
          render
        end
      end

      alias component model

      def filtered?
        search_text.present?
      end

      def picker_path
        @picker_path ||= begin
          base_path, params = manage_component_path(component).split("?")
          params_part = params.blank? ? "" : "?#{params}"
          "#{base_path.sub(%r{/$}, "")}/plans/search_plans#{params_part}"
        end
      end

      def search_text
        params[:q]
      end

      def more_plans?
        @more_plans ||= more_plans_count.positive?
      end

      def more_plans_count
        @more_plans_count ||= plans_count - MAX_PLANS
      end

      def plans_count
        @plans_count ||= filtered_plans.count
      end

      def decorated_plans
        filtered_plans.limit(MAX_PLANS).each do |plan|
          yield Decidim::Plans::PlanPresenter.new(plan)
        end
      end

      def filtered_plans
        @filtered_plans ||= if filtered?
                              filtered_plans_query
                            else
                              plans
                            end
      end

      def filtered_plans_query
        options = {
          organization: model.organization,
          component: plan_components,
          current_user: current_user,
          search_text: search_text
        }
        search = Decidim::Plans::PlanSearch.new(plans, params[:q], options)
        search.result
      end

      def plan_components
        @plan_components ||= component.participatory_space.components.where(manifest_name: "plans")
      end

      def plans
        @plans ||= Decidim.find_resource_manifest(:plans).try(:resource_scope, component)
                     &.published
                     &.not_hidden
                     &.except_withdrawn
                     &.order(id: :asc)
      end

      def plans_collection_name
        Decidim::Plans::Plan.model_name.human(count: 2)
      end
    end
  end
end
