# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user destroys a draft plan.
    class DestroyPlan < Rectify::Command
      # Public: Initializes the command.
      #
      # plan         - The plan to destroy.
      # current_user - The current user.
      def initialize(plan, current_user)
        @plan = plan
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the plan is deleted.
      # - :invalid if the plan is not a draft.
      # - :invalid if the plan's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @plan.draft?
        return broadcast(:invalid) unless @plan.authored_by?(@current_user)

        @plan.destroy!

        broadcast(:ok, @plan)
      end
    end
  end
end
