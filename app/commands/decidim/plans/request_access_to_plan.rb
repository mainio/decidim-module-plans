# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user requests
    # access to edit a plan.
    class RequestAccessToPlan < Decidim::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # plan     - A Decidim::Plans::Plan object.
      # current_user - The current user and requester user
      def initialize(form, current_user)
        @form = form
        @plan = form.plan
        @current_user = current_user
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

        @plan.collaborator_requests.create!(user: @current_user)
        notify_plan_authors
        broadcast(:ok, @plan)
      end

      private

      def notify_plan_authors
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_access_requested",
          event_class: Decidim::Plans::PlanAccessRequestedEvent,
          resource: @plan,
          followers: @plan.authors,
          extra: {
            requester_id: @current_user.id
          }
        )
      end
    end
  end
end
