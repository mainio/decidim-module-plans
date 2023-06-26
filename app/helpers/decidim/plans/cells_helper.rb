# frozen_string_literal: true

module Decidim
  module Plans
    module CellsHelper
      def plans_controller?
        context[:controller].class.to_s == "Decidim::Plans::PlansController"
      end

      def withdrawable?
        return unless from_context
        return unless plans_controller?
        return if index_action?

        from_context.withdrawable_by?(current_user)
      end

      def flaggable?
        return unless from_context
        return unless plans_controller?
        return if index_action?
        return if from_context.try(:official?)

        true
      end
    end
  end
end
