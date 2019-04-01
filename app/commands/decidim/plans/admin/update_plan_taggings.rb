# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user updates a tag.
      class UpdatePlanTaggings < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # plan - The target object to be updated.
        def initialize(form, plan)
          @form = form
          @plan = plan
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the plan.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_plan_taggings

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan

        def update_plan_taggings
          Decidim.traceability.perform_action!(
            :update,
            plan,
            form.current_user
          ) do
            plan.taggings.destroy_all
            plan.update!(
              tags: Tag.where(
                id: form.tags,
                organization: plan.component.organization
              )
            )
          end
        end
      end
    end
  end
end
