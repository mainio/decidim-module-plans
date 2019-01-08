# frozen_string_literal: true

module Decidim
  module Plans
    # Custom helpers, scoped to the proposals engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
      include PaginateHelper
      include Decidim::MapHelper

      # Public: The state of a proposal in a way a human can understand.
      #
      # state - The String state of the proposal.
      #
      # Returns a String.
      def humanize_plan_state(state)
        I18n.t(state, scope: "decidim.proposals.answers", default: :not_answered)
      end

      # Public: The css class applied based on the proposal state.
      #
      # state - The String state of the proposal.
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
        Plan.where(component: current_component, author: current_user)
      end

      def authors_for(plan)
        plan.identities.map { |identity| present(identity) }
      end

      def filter_state_values
        [
          ["except_rejected", t("decidim.proposals.application_helper.filter_state_values.except_rejected")],
          ["accepted", t("decidim.proposals.application_helper.filter_state_values.accepted")],
          ["evaluating", t("decidim.proposals.application_helper.filter_state_values.evaluating")],
          ["rejected", t("decidim.proposals.application_helper.filter_state_values.rejected")],
          ["all", t("decidim.proposals.application_helper.filter_state_values.all")]
        ]
      end

      def filter_type_values
        [
          ["all", t("decidim.proposals.application_helper.filter_type_values.all")],
          ["proposals", t("decidim.proposals.application_helper.filter_type_values.proposals")],
          ["amendments", t("decidim.proposals.application_helper.filter_type_values.amendments")]
        ]
      end
    end
  end
end
