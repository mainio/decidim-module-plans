# frozen_string_literal: true

module Decidim
  module Plans
    # A factory class to ensure we always create Plans the same way since it involves some logic.
    module PlanBuilder
      # Public: Creates a new Plan.
      #
      # attributes        - The Hash of attributes to create the Plan with.
      # author            - An Authorable the will be the first coauthor of the Plan.
      # user_group_author - A User Group to, optionally, set it as the author too.
      # action_user       - The User to be used as the user who is creating the plan in the traceability logs.
      #
      # Returns a Plan.
      def create(attributes:, author:, action_user:, user_group_author: nil)
        Decidim.traceability.perform_action!(:create, Plan, action_user, visibility: "all") do
          plan = Plan.new(attributes)
          plan.add_coauthor(author, user_group: user_group_author)
          plan.save!
          plan
        end
      end

      module_function :create

      # Public: Creates a new Plan by copying the attributes from another one.
      #
      # original_plan     - The Plan to be used as base to create the new one.
      # author            - An Authorable the will be the first coauthor of the Plan.
      # user_group_author - A User Group to, optionally, set it as the author too.
      # action_user       - The User to be used as the user who is creating the plan in the traceability logs.
      # extra_attributes  - A Hash of attributes to create the new plan, will overwrite the original ones.
      # skip_link         - Whether to skip linking the two plans or not (default false).
      #
      # Returns a Plan
      #
      # rubocop:disable Metrics/ParameterLists
      def copy(original_plan, author:, action_user:, user_group_author: nil, extra_attributes: {}, skip_link: false)
        origin_attributes = original_plan.attributes.except(
          "id",
          "created_at",
          "updated_at",
          "state",
          "answer",
          "answered_at",
          "decidim_component_id"
        ).merge(
          "category" => original_plan.category
        ).merge(
          extra_attributes
        )

        plan = create(
          attributes: origin_attributes,
          author:,
          user_group_author:,
          action_user:
        )

        plan.link_resources(original_plan, "copied_from_component") unless skip_link
        plan
      end
      # rubocop:enable Metrics/ParameterLists

      module_function :copy
    end
  end
end
