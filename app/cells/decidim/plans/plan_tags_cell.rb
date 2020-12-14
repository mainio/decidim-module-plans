# frozen_string_literal: true

module Decidim
  module Plans
    # This cell renders the tags for a idea.
    class PlanTagsCell < Decidim::ViewModel
      include Decidim::Plans::CellContentHelper

      alias plan model

      def show
        render if has_category_or_area_scope?
      end

      private

      def current_component
        context[:current_component]
      end
    end
  end
end
