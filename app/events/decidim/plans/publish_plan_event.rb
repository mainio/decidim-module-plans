# frozen_string_literal: true

module Decidim
  module Plans
    class PublishPlanEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::CoauthorEvent

      def resource_text
        # TODO
      end

      private

      def i18n_scope
        return "decidim.events.plans.plan_published_for_space" if participatory_space_event?
        return "decidim.events.plans.plan_published_for_proposals" if proposal_author_event?

        super
      end

      def participatory_space_event?
        extra[:participatory_space]
      end

      def proposal_author_event?
        extra[:proposal_author]
      end
    end
  end
end
