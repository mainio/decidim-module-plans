# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes Plan versions so users can see how a Plan
    # has been updated through time.
    class VersionsController < Decidim::Plans::ApplicationController
      helper Decidim::Plans::TraceabilityHelper
      helper_method :current_version, :item

      private

      def item
        @item ||= Plan.where(component: current_component).find(params[:plan_id])
      end

      def current_version
        return nil if params[:id].to_i < 1
        @current_version ||= item.versions[params[:id].to_i - 1]
      end
    end
  end
end
