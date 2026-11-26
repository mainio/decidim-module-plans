# frozen_string_literal: true

module Decidim
  module Plans
    class PlanWidgetsController < Decidim::ApplicationController
      helper Plans::ApplicationHelper

      private

      def model
        # component scopes it to organization
        # rubocop:disable Decidim/OrganizationScopedFinder
        @model ||= Plan.where(component: params[:component_id]).find(params[:plan_id])
        # rubocop:enable Decidim/OrganizationScopedFinder
      end

      def iframe_url
        @iframe_url ||= plan_plan_widget_url(model)
      end
    end
  end
end
