# frozen_string_literal: true

module Decidim
  module Plans
    # Custom helpers, scoped to the plans engine.
    #
    module ApplicationHelper
      include Decidim::Plans::LinksHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include Decidim::MapHelper

      # Public: The state of a plan in a way a human can understand.
      #
      # state - The String state of the plan.
      #
      # Returns a String.
      def humanize_plan_state(state)
        I18n.t(state, scope: "decidim.plans.answers", default: :not_answered)
      end

      # Public: The css class applied based on the plan state.
      #
      # state - The String state of the plan.
      #
      # Returns a String.
      def plan_state_css_class(state)
        case state
        when "accepted"
          "text-success"
        when "rejected"
          "text-alert"
        when "evaluating"
          "text-warning"
        when "withdrawn"
          "text-alert"
        else
          "text-info"
        end
      end

      def current_user_plans
        Plan.joins(:coauthorships).where(
          component: current_component,
          decidim_coauthorships: {
            decidim_author_id: current_user.id,
            decidim_author_type: "Decidim::UserBaseEntity"
          }
        )
      end

      def authors_for(plan)
        plan.identities.map { |identity| present(identity) }
      end

      def filter_state_values
        [
          ["all", t("decidim.plans.application_helper.filter_state_values.all")],
          ["accepted", t("decidim.plans.application_helper.filter_state_values.accepted")],
          ["rejected", t("decidim.plans.application_helper.filter_state_values.rejected")],
          ["evaluating", t("decidim.plans.application_helper.filter_state_values.evaluating")]
        ]
      end

      def filter_type_values
        [
          ["all", t("decidim.plans.application_helper.filter_type_values.all")],
          ["plans", t("decidim.plans.application_helper.filter_type_values.plans")],
          ["amendments", t("decidim.plans.application_helper.filter_type_values.amendments")]
        ]
      end

      def tabs_id_for_content(idx)
        "content_#{idx}"
      end
    end
  end
end
