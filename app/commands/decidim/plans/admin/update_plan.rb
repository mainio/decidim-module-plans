# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user updates a plan.
      class UpdatePlan < Rectify::Command
        include ::Decidim::Plans::AttachmentMethods
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
              link_proposals
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

        def link_proposals
          plan.link_resources(proposals, "included_proposals")
        end

        def attributes
          {
            title: form.title,
            category: form.category,
            scope: form.scope,
            # The update token ensures a new version is always created even if
            # the other attributes have not changed. This is needed to force a
            # new version to show the changes to associated models.
            update_token: Time.now.to_f,
            # Optional version comments to be stored against the version
            version_comment: form.version_comment
          }
        end

        def proposals
          @proposals ||= plan.sibling_scope(:proposals).where(
            id: form.proposal_ids
          )
        end
      end
    end
  end
end
