# frozen_string_literal: true

module Decidim
  module Plans
    module CellsHelper
      def plans_controller?
        context[:controller].instance_of?(::Decidim::Plans::PlansController)
      end

      def withdrawable?
        return false unless from_context
        return false unless plans_controller?
        return false if index_action?

        from_context.withdrawable_by?(current_user)
      end

      def flaggable?
        return false unless from_context
        return false unless plans_controller?
        return false if index_action?
        return false if from_context.try(:official?)

        true
      end
    end
  end
end
