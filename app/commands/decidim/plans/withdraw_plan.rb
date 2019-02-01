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
        # return broadcast(:invalid) if @plan.votes.any?

        transaction do
          change_plan_state_to_withdrawn
          # reject_emendations_if_any # 0.16+
        end

        broadcast(:ok, @plan)
      end

      private

      def change_plan_state_to_withdrawn
        @plan.update state: "withdrawn"
      end

      def reject_emendations_if_any
        return if @plan.emendations.empty?

        @plan.emendations.each do |emendation|
          @form = form(Decidim::Amendable::RejectForm).from_params(id: emendation.amendment.id)
          result = Decidim::Amendable::Reject.call(@form)
          return result[:ok] if result[:ok]
        end
      end
    end
  end
end
