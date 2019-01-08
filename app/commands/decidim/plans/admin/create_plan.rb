# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user creates a new plan.
      class CreatePlan < Rectify::Command
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
            create_attachment if process_attachments?
            send_notification
          end

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan, :attachment

        def create_plan
          @plan = Decidim::Plans::PlanBuilder.create(
            attributes: attributes,
            author: form.author,
            action_user: form.current_user
          )
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

        def build_attachment
          @attachment = Attachment.new(
            title: form.attachment.title,
            file: form.attachment.file,
            attached_to: @plan
          )
        end

        def attachment_invalid?
          if attachment.invalid? && attachment.errors.has_key?(:file)
            form.attachment.errors.add :file, attachment.errors[:file]
            true
          end
        end

        def attachment_present?
          attachments_allowed? && form.attachment.file.present?
        end

        def create_attachment
          attachment.attached_to = plan
          attachment.save!
        end

        def attachments_allowed?
          form.current_component.settings.attachments_allowed?
        end

        def process_attachments?
          attachments_allowed? && attachment_present?
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
