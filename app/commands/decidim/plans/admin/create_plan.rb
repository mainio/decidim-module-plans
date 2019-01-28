# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user creates a new plan.
      class CreatePlan < Rectify::Command
        include AttachmentMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the plan.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachment
            return broadcast(:invalid) if attachment_invalid?
          end

          transaction do
            create_plan
            create_plan_contents
            create_attachment if process_attachments?
            send_notification
          end

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan, :attachment

        def create_plan
          @plan = Decidim::Plans::PlanBuilder.create(
            attributes: { published_at: Time.current }.merge(attributes),
            author: form.author,
            action_user: form.current_user
          )
          @plan.proposals << form.proposals
          @attached_to = @plan
        end

        def create_plan_contents
          @form.contents.each do |content|
            @plan.contents.create!(
              body: content.body,
              section: content.section,
              user: form.current_user
            )
          end
        end

        def attributes
          {
            title: form.title,
            category: form.category,
            scope: form.scope,
            component: form.component,
            published_at: Time.current
          }
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.plans.plan_published",
            event_class: Decidim::Plans::PublishPlanEvent,
            resource: plan,
            recipient_ids: @plan.participatory_space.followers.pluck(:id),
            extra: {
              participatory_space: true
            }
          )
        end
      end
    end
  end
end
