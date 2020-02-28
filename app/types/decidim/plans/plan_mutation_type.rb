# frozen_string_literal: true

module Decidim
  module Plans
    class PlanMutationType < GraphQL::Schema::Object
      graphql_name "PlanMutation"
      description "A plan which includes its available mutations"

      field :id, ID, null: false

      field :answer, Decidim::Plans::PlanType, null: true do
        description "Answer a plan"

        argument :state, String, description: "The answer status in which plan is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
        argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this plan", required: false
      end

      def answer(state:, answer_content: nil)
        enforce_permission_to :create, :plan_answer

        params = {
          "plan_answer" => {
            "state" => state,
            "answer" => answer_content
          }
        }
        form = Decidim::Plans::Admin::PlanAnswerForm.from_params(
          params
        ).with_context(
          current_organization: context[:current_organization],
          current_user: context[:current_user]
        )

        plan = object
        Decidim::Plans::Admin::AnswerPlan.call(form, plan) do
          on(:ok) do
            return plan
          end
        end
      end

      private

      def current_user
        context[:current_user]
      end

      def enforce_permission_to(action, subject, extra_context = {})
        raise Decidim::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {}, user = current_user)
        scope ||= :admin
        permission_action = Decidim::PermissionAction.new(scope: scope, action: action, subject: subject)

        Decidim::Plans::Admin::Permissions.new(
          user,
          permission_action,
          permissions_context.merge(extra_context)
        ).permissions.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Admin::ApplicationController)
      end

      def permissions_context
        {
          current_settings: object.component.current_settings,
          component_settings: object.component.settings,
          current_organization: object.organization,
          current_component: object.component
        }
      end
    end
  end
end
