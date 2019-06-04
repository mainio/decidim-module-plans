# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user creates a new plan.
    class CreatePlan < Rectify::Command
      include AttachmentMethods
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
        @attached_to = nil
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
          end
        end

        broadcast(:ok, plan)
      end

      private

      attr_reader :form, :plan, :attachments

      def create_plan
        @plan = Decidim::Plans.loggability.perform_action!(
          :create,
          Plan,
          @form.current_user
        ) do
          plan = Plan.new(
            title: form.title,
            category: form.category,
            scope: form.scope,
            component: form.component,
            state: "open"
          )
          plan.coauthorships.build(author: @current_user, user_group: @form.user_group)
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
            user: @current_user
          )
        end
      end

      def link_proposals
        plan.link_resources(proposals, "included_proposals")
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(organization: organization, id: form.user_group_id)
      end

      def organization
        @organization ||= @current_user.organization
      end

      def proposals
        @proposals ||= plan.sibling_scope(:proposals).where(
          id: @form.proposal_ids
        )
      end
    end
  end
end
