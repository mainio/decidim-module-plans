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
          answer_plan
          send_notification
          send_notification_to_participatory_space
          send_notification_to_proposal_authors
        end

        broadcast(:ok, @plan)
      end

      private

      attr_reader :plan

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

      def answer_plan
        default_state = @plan.component.settings.default_state
        return if default_state.blank?

        default_answer = @plan.component.settings.default_answer
        default_answer = nil if default_answer.all? do |_key, val|
          val.blank?
        end

        Decidim.traceability.perform_action!(
          "publish",
          @plan,
          @current_user,
          visibility: "public-only"
        ) do
          @plan.update!(
            state: default_state,
            answer: default_answer,
            answered_at: Time.current
          )
        end
      end

      def send_notification
        return if @plan.coauthorships.empty?

        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_published",
          event_class: Decidim::Plans::PublishPlanEvent,
          resource: @plan,
          followers: coauthors_followers
        )
      end

      def send_notification_to_participatory_space
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_published",
          event_class: Decidim::Plans::PublishPlanEvent,
          resource: @plan,
          followers: @plan.participatory_space.followers - coauthors_followers,
          extra: {
            participatory_space: true
          }
        )
      end

      def send_notification_to_proposal_authors
        Decidim::EventsManager.publish(
          event: "decidim.events.plans.plan_published",
          event_class: Decidim::Plans::PublishPlanEvent,
          resource: @plan,
          followers: proposal_authors,
          extra: {
            proposal_author: true
          }
        )
      end

      def coauthors_followers
        @coauthors_followers ||= @plan.authors.flat_map(&:followers)
      end

      def proposal_authors
        @proposal_authors ||= begin
          proposals = plan.linked_resources(:proposals, "included_proposals")
          proposals.flat_map(&:authors).select { |a| a.is_a?(Decidim::User) }
        end
      end
    end
  end
end
