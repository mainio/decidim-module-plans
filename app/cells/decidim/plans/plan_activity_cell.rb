# frozen_string_literal: true

module Decidim
  module Plans
    # A cell to display when a plan has been published.
    class PlanActivityCell < ActivityCell
      def title
        I18n.t(
          "decidim.plans.last_activity.new_plan_at_html",
          link: participatory_space_link
        )
      end

      def resource_link_text
        Decidim::Plans::PlanPresenter.new(resource).title
      end
    end
  end
end
