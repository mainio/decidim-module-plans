# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user withdraws a plan.
    class WithdrawPlan < Rectify::Command
      # Public: Initializes the command.
      #
      # plan         - The plan to withdraw.
      # current_user - The current user.
      def initialize(plan, current_user)
        @plan = plan
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the proposal already has supports or does not belong to current user.
      #
      # Returns nothing.
      def call
        transaction do
          change_plan_state_to_withdrawn
        end

        broadcast(:ok, @plan)
      end

      private

      def change_plan_state_to_withdrawn
        @plan.update state: "withdrawn"
      end
    end
  end
end
