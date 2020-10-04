# frozen_string_literal: true

module Decidim
  module Plans
    class PlanMutationType < GraphQL::Schema::Object
      graphql_name "PlanMutation"
      description "A plan which includes its available mutations"

      field :id, ID, null: false

      field :update, Decidim::Plans::PlanType, null: true do
        description "The content mutations to be updated."

        argument :title, GraphQL::Types::JSON, description: "The plan title localized hash, e.g. {\"en\": \"English title\"}", required: true
        argument :contents, [Decidim::Plans::ContentMutationAttributes], required: true
        argument :version_comment, GraphQL::Types::JSON, description: "The plan version comment localized hash, e.g. {\"en\": \"Fixed a typo\"}", required: false
      end

      field :answer, Decidim::Plans::PlanType, null: true do
        description "Answer a plan"

        argument :state, String, description: "The answer status in which plan is in. Can be one of 'accepted', 'rejected' or 'evaluating'", required: true
        argument :answer_content, GraphQL::Types::JSON, description: "The answer feedback for the status for this plan", required: false
      end

      def update(title:, contents:, version_comment: nil)
        enforce_permission_to :edit, :plan, plan: object

        params = {
          "plan" => {
            "title" => title || object.title,
            "version_comment" => version_comment,
            "contents" => contents.map do |content|
              next unless content
              next unless content.decidim_plan_id == object.id

              {
                "id" => content.id,
                "section_id" => content.section.id,
                "body" => content.body
              }
            end.compact
          }
        }
        form = Decidim::Plans::Admin::PlanForm.from_params(
          params
        ).with_context(
          current_organization: context[:current_organization],
          current_participatory_space: object.component.participatory_space,
          current_component: object.component,
          current_user: context[:current_user]
        )

        Decidim::Plans::Admin::UpdatePlan.call(form, object) do
          on(:ok) do
            return object
          end
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(', ')
            )
          end
        end

        GraphQL::ExecutionError.new(I18n.t("decidim.plans.plans.update.error"))
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
          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(', ')
            )
          end
        end

        GraphQL::ExecutionError.new(
          I18n.t("decidim.plans.admin.plans.answer.invalid")
        )
      end

      private

      def current_user
        context[:current_user]
      end

      def enforce_permission_to(action, subject, extra_context = {})
        raise Decidim::Plans::ActionForbidden unless allowed_to?(action, subject, extra_context)
      end

      def allowed_to?(action, subject, extra_context = {}, user = current_user)
        scope ||= :admin
        permission_action = Decidim::PermissionAction.new(scope: scope, action: action, subject: subject)

        permission_class_chain.inject(permission_action) do |current_permission_action, permission_class|
          permission_class.new(
            user,
            current_permission_action,
            permissions_context.merge(extra_context)
          ).permissions
        end.allowed?
      rescue Decidim::PermissionAction::PermissionNotSetError
        false
      end

      def permission_class_chain
        [
          object.component.manifest.permissions_class,
          object.participatory_space.manifest.permissions_class,
          ::Decidim::Admin::Permissions,
          ::Decidim::Permissions
        ]
      end

      def permissions_context
        {
          current_settings: object.component.current_settings,
          component_settings: object.component.settings,
          current_organization: object.organization,
          current_component: object.component
        }
      end

      class ::Decidim::Plans::ActionForbidden < StandardError
      end
    end
  end
end
