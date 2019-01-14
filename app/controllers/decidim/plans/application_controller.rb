# frozen_string_literal: true

module Decidim
  module Plans
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::Messaging::ConversationHelper
      helper_method :plan_limit_reached?

      def plan_limit
        return nil if component_settings.plan_limit.zero?
        component_settings.plan_limit
      end

      def plan_limit_reached?
        return false unless plan_limit

        plans.where(author: current_user).count >= plan_limit
      end

      def plans
        Plan.where(component: current_component)
      end
    end
  end
end
