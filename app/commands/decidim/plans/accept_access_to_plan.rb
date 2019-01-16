# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic to accept a user request to
    # contribute to a plan.
    class AcceptAccessToPlan < RespondToAccessRequest
      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if it wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) if @current_user.nil?

        transaction do
          @plan.requesters.delete @requester_user

          Decidim::Coauthorship.create(
            coauthorable: @plan,
            author: @requester_user
          )
        end

        notify_plan_requester
        notify_plan_authors
        broadcast(:ok, @requester_user)
      end

      def recipient_ids
        @plan.authors.pluck(:id) - [@requester_user.id]
      end

      def authors_event
        "decidim.events.plans.plan_access_accepted"
      end

      def authors_event_class
        Decidim::Plans::PlanAccessAcceptedEvent
      end

      def requester_event
        "decidim.events.plans.plan_access_requester_accepted"
      end

      def requester_event_class
        Decidim::Plans::PlanAccessRequesterAcceptedEvent
      end
    end
  end
end
