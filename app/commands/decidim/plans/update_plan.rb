# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user updates a plan.
    class UpdatePlan < Rectify::Command
      include AttachmentMethods
      include NestedUpdater

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # plan - the plan to update.
      def initialize(form, current_user, plan)
        @form = form
        @current_user = current_user
        @plan = plan
        @attached_to = plan
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the plan.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless plan.editable_by?(current_user)

        if process_attachments?
          prepare_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if form.invalid?
          mark_attachment_reattachment
          return broadcast(:invalid)
        end

        transaction do
          update_plan
          update_plan_contents
          update_attachments if process_attachments?
        end

        broadcast(:ok, plan)
      end

      private

      attr_reader :form, :plan, :current_user, :attachments

      def update_plan
        Decidim.traceability.update!(
          @plan,
          @current_user,
          attributes
        )
      end

      def update_plan_contents
        @form.contents.each do |content|
          update_nested_model(
            content,
            { body: content.body,
              section: content.section,
              user: @form.current_user },
            @plan.contents
          )
        end
      end

      def attributes
        {
          title: @form.title,
          category: @form.category,
          scope: @form.scope,
          proposals: @form.proposals
        }
      end
    end
  end
end
