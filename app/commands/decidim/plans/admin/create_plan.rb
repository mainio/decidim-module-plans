# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user creates a new plan.
      class CreatePlan < Rectify::Command
        include ::Decidim::Plans::AttachmentMethods

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
          if process_attachments?
            return broadcast(:invalid) if attachments_invalid?
          end

          if form.invalid?
            mark_attachment_reattachment
            return broadcast(:invalid)
          end

          Decidim::Plans.tracer.trace!(@form.current_user) do
            transaction do
              create_plan
              create_plan_contents
              link_proposals
              update_attachments if process_attachments?
              answer_plan
              send_notification
            end
          end

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan, :attachment

        def create_plan
          @plan = Decidim::Plans.loggability.perform_action!(
            :create,
            Plan,
            @form.current_user
          ) do
            plan = Plan.new(
              { published_at: Time.current }.merge(attributes)
            )
            plan.coauthorships.build(author: form.author)
            plan.save!
            plan
          end

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

        def link_proposals
          plan.link_resources(proposals, "included_proposals")
        end

        def answer_plan
          default_state = @plan.component.settings.default_state
          return if default_state.nil?
          return if default_state.empty?

          default_answer = @plan.component.settings.default_answer

          default_answer = nil if default_answer.all? do |_key, val|
            val.empty?
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

        def attributes
          {
            title: form.title,
            category: form.category,
            scope: form.scope,
            component: form.component,
            state: "open",
            published_at: Time.current
          }
        end

        def proposals
          @proposals ||= plan.sibling_scope(:proposals).where(
            id: @form.proposal_ids
          )
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.plans.plan_published",
            event_class: Decidim::Plans::PublishPlanEvent,
            resource: plan,
            followers: plan.participatory_space.followers,
            extra: {
              participatory_space: true
            }
          )
        end
      end
    end
  end
end
