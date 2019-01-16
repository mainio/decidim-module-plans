# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic to accept a user request to
    # contribute to a collaborative draft.
    class AcceptAccessToPlan < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # plan     - A Decidim::Plans::Plan object.
      # current_user - The current user.
      # requester_user - The user that requested to collaborate.
      def initialize(form, current_user)
        @form = form
        @plan = form.plan
        @current_user = current_user
        @requester_user = form.requester_user
      end

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

      private

      def notify_plan_authors
        recipient_ids = @plan.authors.pluck(:id) - [@requester_user.id]
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_access_accepted",
          event_class: Decidim::Plans::PlanAccessAcceptedEvent,
          resource: @plan,
          recipient_ids: recipient_ids.uniq,
          extra: {
            requester_id: @requester_user.id
          }
        )
      end

      def notify_plan_requester
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_access_requester_accepted",
          event_class: Decidim::Plans::PlanAccessRequesterAcceptedEvent,
          resource: @plan,
          recipient_ids: [@requester_user.id]
        )
      end
    end
  end
end
