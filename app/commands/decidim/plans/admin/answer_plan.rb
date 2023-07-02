# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when an admin answers a plan.
      class AnswerPlan < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # plan - The plan to write the answer for.
        def initialize(form, plan)
          @form = form
          @plan = plan
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          answer_plan
          notify_followers

          broadcast(:ok)
        end

        private

        attr_reader :form, :plan

        def answer_plan
          Decidim.traceability.perform_action!(
            "answer",
            plan,
            form.current_user
          ) do
            closed_at = plan.closed_at || Time.current

            plan.update!(
              closed_at: closed_at,
              state: @form.state,
              answer: @form.answer,
              answered_at: Time.current
            )
          end
        end

        def notify_followers
          return if (plan.previous_changes.keys & %w(state)).empty?

          if plan.accepted?
            publish_event(
              "decidim.events.plans.plan_accepted",
              Decidim::Plans::AcceptedPlanEvent
            )
          elsif plan.rejected?
            publish_event(
              "decidim.events.plans.plan_rejected",
              Decidim::Plans::RejectedPlanEvent
            )
          elsif plan.evaluating?
            publish_event(
              "decidim.events.plans.plan_evaluating",
              Decidim::Plans::EvaluatingPlanEvent
            )
          end
        end

        def publish_event(event, event_class)
          Decidim::EventsManager.publish(
            event: event,
            event_class: event_class,
            resource: plan,
            affected_users: plan.notifiable_identities,
            followers: plan.followers - plan.notifiable_identities
          )
        end
      end
    end
  end
end
