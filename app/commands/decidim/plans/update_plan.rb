# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user updates a plan.
    class UpdatePlan < Decidim::Command
      include Decidim::Plans::PlanContentMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # plan - the plan to update.
      def initialize(form, current_user, plan)
        @form = form
        @current_user = current_user
        @plan = plan
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the plan.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless plan.editable_by?(current_user)

        prepare_plan_contents
        if form.invalid?
          fail_plan_contents
          return broadcast(:invalid)
        end

        Decidim::Plans.tracer.trace!(@current_user) do
          transaction do
            update_plan
            save_plan_contents
            plan.save! if plan.changed?
          end
        end

        finalize_plan_contents

        broadcast(:ok, plan)
      end

      private

      attr_reader :form, :plan, :current_user

      def update_plan
        Decidim::Plans.loggability.update!(
          @plan,
          @current_user,
          attributes
        )
      end

      def attributes
        {
          # The update token ensures a new version is always created even if
          # the other attributes have not changed. This is needed to force a new
          # version to show the changes to associated models.
          update_token: Time.now.to_f
        }
      end

      def proposals
        @proposals ||= plan.sibling_scope(:proposals).where(
          id: @form.proposal_ids
        )
      end
    end
  end
end
