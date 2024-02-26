# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders a map with the geolocated plans (or a single plan).
    class PlansMapCell < Decidim::ViewModel
      include Decidim::MapHelper
      include Decidim::Plans::PlansHelper
      include Decidim::Plans::Engine.routes.url_helpers

      delegate :current_component, :snippets, to: :controller

      def popup_template
        return if disable_popup?

        render :popup_template
      end

      private

      def map_data
        plans_data_for_map(geolocated_data)
      end

      def map_options
        options[:map_options] || {}
      end

      def disable_popup?
        options[:disable_popup] == true
      end

      def geolocated_data
        return geolocated_data_for(model) if model.is_a?(Decidim::Plans::Plan)

        model
      end

      def geolocated_data_for(plan)
        Decidim::Plans::Plan.where(id: plan.id).geocoded_data_for(plan.component)
      end
    end
  end
end
