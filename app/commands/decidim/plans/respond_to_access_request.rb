# frozen_string_literal: true

module Decidim
  module Plans
    # Common functionality for {Accept,Reject}AccessToPlan.
    class RespondToAccessRequest < Decidim::Command
      # Public: Initializes the command.
      #
      # form     - A form object with the params.
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

      def notify_plan_authors
        Decidim::EventsManager.publish(
          event: authors_event,
          event_class: authors_event_class,
          resource: @plan,
          followers: recipients.uniq,
          extra: {
            requester_id: @requester_user.id
          }
        )
      end

      def notify_plan_requester
        Decidim::EventsManager.publish(
          event: requester_event,
          event_class: requester_event_class,
          resource: @plan,
          affected_users: [@requester_user]
        )
      end

      def recipients; end

      def authors_event; end

      def authors_event_class; end

      def requester_event; end

      def requester_event_class; end
    end
  end
end
