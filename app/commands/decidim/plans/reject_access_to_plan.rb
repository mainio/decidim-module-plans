# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic to reject a user request to
    # contribute to a plan.
    class RejectAccessToPlan < RespondToAccessRequest
      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if it wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) if @current_user.nil?

        @plan.requesters.delete @requester_user

        notify_plan_requester
        notify_plan_authors
        broadcast(:ok, @requester_user)
      end

      def recipient_ids
        @plan.authors.pluck(:id)
      end

      def authors_event
        "decidim.events.plans.plan_access_rejected"
      end

      def authors_event_class
        Decidim::Plans::PlanAccessRejectedEvent
      end

      def requester_event
        "decidim.events.plans.plan_access_requester_rejected"
      end

      def requester_event_class
        Decidim::Plans::PlanAccessRequesterRejectedEvent
      end
    end
  end
end
