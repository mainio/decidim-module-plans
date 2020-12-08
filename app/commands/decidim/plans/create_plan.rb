# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when a user creates a new plan.
    class CreatePlan < Rectify::Command
      include Decidim::Plans::PlanContentMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
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

        Decidim::Plans.tracer.trace!(@form.current_user) do
          transaction do
            create_plan
            save_plan_contents
            plan.save! if plan.changed?
          end
        end

        finalize_plan_contents

        broadcast(:ok, plan)
      end

      private

      attr_reader :form, :plan

      def create_plan
        @plan = Decidim::Plans.loggability.perform_action!(
          :create,
          Plan,
          @form.current_user
        ) do
          plan = Plan.new(
            component: form.component,
            state: "open"
          )
          plan.coauthorships.build(author: @current_user, user_group: @form.user_group)
          plan.save!
          plan
        end
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
