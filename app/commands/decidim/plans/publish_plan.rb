# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user creates a new plan.
    class PublishPlan < Rectify::Command
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
        return broadcast(:invalid) unless @plan.authored_by?(@current_user)

        transaction do
          publish_plan
          send_notification
          send_notification_to_participatory_space
        end

        broadcast(:ok, @plan)
      end

      private

      def publish_plan
        Decidim.traceability.perform_action!(
          "publish",
          @plan,
          @current_user,
          visibility: "public-only"
        ) do
          @plan.update published_at: Time.current
        end
      end

      def send_notification
        return if @plan.coauthorships.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_published",
          event_class: Decidim::Plans::PublishPlanEvent,
          resource: @plan,
          recipient_ids: coauthors_followers
        )
      end

      def send_notification_to_participatory_space
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_published",
          event_class: Decidim::Plans::PublishPlanEvent,
          resource: @plan,
          recipient_ids: @plan.participatory_space.followers.pluck(:id) - coauthors_followers,
          extra: {
            participatory_space: true
          }
        )
      end

      def coauthors_followers
        followers_ids = []
        @plan.authors.each do |author|
          followers_ids += author.followers.pluck(:id)
        end
        followers_ids
      end
    end
  end
end
