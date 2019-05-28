# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user updates a plan.
      class UpdatePlan < Rectify::Command
        include AttachmentMethods
        include NestedUpdater

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # plan         - the plan to update.
        def initialize(form, plan)
          @form = form
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
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            prepare_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          if form.invalid?
            mark_attachment_reattachment
            return broadcast(:invalid)
          end

          Decidim::Plans.tracer.trace!(form.current_user) do
            transaction do
              update_plan
              update_plan_contents
              update_attachments if process_attachments?
            end
          end

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan, :attachment

        def update_plan
          Decidim::Plans.loggability.update!(
            plan,
            form.current_user,
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
            title: form.title,
            category: form.category,
            scope: form.scope,
            proposals: form.proposals,
            # The update token ensures a new version is always created even if
            # the other attributes have not changed. This is needed to force a
            # new version to show the changes to associated models.
            update_token: Time.now.to_f
          }
        end
      end
    end
  end
end
