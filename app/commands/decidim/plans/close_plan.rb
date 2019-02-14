# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user closes a plan.
    class ClosePlan < Rectify::Command
      # Public: Initializes the command.
      #
      # plan         - The plan to publish.
      # current_user - The current user.
      def initialize(plan, current_user)
        @plan = plan
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the plan is published.
      # - :invalid if the plan's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @current_user.nil?

        close_plan

        broadcast(:ok, @plan)
      end

      private

      def close_plan
        Decidim.traceability.perform_action!(
          "close",
          @plan,
          @current_user,
          visibility: "public-only"
        ) do
          @plan.update closed_at: Time.current
        end
      end
    end
  end
end
