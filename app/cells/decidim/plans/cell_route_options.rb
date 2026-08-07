# frozen_string_literal: true

module Decidim
  module Plans
    module CellRouteOptions
      extend ActiveSupport::Concern

      private

      def default_url_options
        return {} unless respond_to?(:current_component) && current_component

        {
          participatory_process_slug: current_component.participatory_space.slug,
          component_id: current_component.id
        }
      end
    end
  end
end
