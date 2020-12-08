# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user updates a plan.
      class UpdatePlan < Rectify::Command
        include Decidim::Plans::PlanContentMethods

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # plan         - the plan to update.
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
          prepare_plan_contents
          if form.invalid?
            fail_plan_contents
            return broadcast(:invalid)
          end

          Decidim::Plans.tracer.trace!(form.current_user) do
            transaction do
              update_plan
              save_plan_contents
            end
          end

          finalize_plan_contents

          broadcast(:ok, plan)
        end

        private

        attr_reader :form, :plan

        def update_plan
          Decidim::Plans.loggability.update!(
            plan,
            form.current_user,
            attributes
          )
        end

        def attributes
          {
            # The update token ensures a new version is always created even if
            # the other attributes have not changed. This is needed to force a
            # new version to show the changes to associated models.
            update_token: Time.now.to_f,
            # Optional version comments to be stored against the version
            version_comment: form.version_comment
          }
        end
      end
    end
  end
end
