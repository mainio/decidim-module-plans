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

          transaction do
            update_plan
            update_plan_contents
            update_plan_author
            update_attachments if process_attachments?
          end

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan, :attachment

        def update_plan
          Decidim.traceability.update!(
            plan,
            form.current_user,
            title: form.title,
            category: form.category,
            scope: form.scope,
            proposals: form.proposals
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

        def update_plan_author
          plan.coauthorships.clear
          plan.add_coauthor(form.author)
          plan.save!
          plan
        end
      end
    end
  end
end
