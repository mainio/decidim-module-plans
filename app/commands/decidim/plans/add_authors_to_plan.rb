# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when new authors are added to a
    # plan.
    class AddAuthorsToPlan < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # plan         - The plan for which to add the authors.
      # current_user - The current user.
      def initialize(form, plan, current_user)
        @form = form
        @plan = plan
        @current_user = current_user
        @new_authors = []
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the plan is published.
      # - :invalid if the plan's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.authors.any?

        add_authors
        notify_new_authors

        broadcast(:ok, plan)
      end

      private

      attr_reader :form, :plan, :new_authors

      def add_authors
        transaction do
          form.authors.each do |author_user|
            next if plan.authors.include?(author_user)

            Decidim::Coauthorship.create(
              coauthorable: plan,
              author: author_user
            )
            new_authors << author_user
          end
        end
      end

      def notify_new_authors
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_access_granted",
          event_class: Decidim::Plans::PlanAccessGrantedEvent,
          resource: plan,
          affected_users: new_authors
        )
      end
    end
  end
end
