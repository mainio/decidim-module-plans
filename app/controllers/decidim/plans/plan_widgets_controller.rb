# frozen_string_literal: true

module Decidim
  module Plans
    class PlanWidgetsController < Decidim::WidgetsController
      helper Plans::ApplicationHelper

      private

      def model
        @model ||= Plan.where(component: params[:component_id]).find(params[:plan_id])
      end

      def iframe_url
        @iframe_url ||= plan_plan_widget_url(model)
      end
    end
  end
end
