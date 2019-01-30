# frozen_string_literal: true

module Decidim
  module Plans
    module Log
      class ResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          Decidim::Plans::PlanPresenter.new(resource).title if resource
        end
      end
    end
  end
end
