# frozen_string_literal: true

module Decidim
  module Plans
    class PlansType < GraphQL::Schema::Object
      graphql_name "Plans"
      description "A plans component of a participatory space."

      implements Decidim::Core::ComponentInterface

      field :plans, Decidim::Plans::PlanType.connection_type, description: "List all plans", null: true do
        argument :order, Decidim::Plans::PlanInputSort, "Provides several methods to order the results", required: false
        argument :filter, Decidim::Plans::PlanInputFilter, "Provides several methods to filter the results", required: false
      end

      field :sections, SectionType.connection_type, null: true

      field(:plan, Decidim::Plans::PlanType, null: true) do
        argument :id, ID, required: true
      end

      def plans(filter: {}, order: {})
        Decidim::Plans::PlanListHelper.new(model_class: Plan).call(object, { filter: filter, order: order }, context)
      end

      def sections
        Decidim::Plans::SectionListHelper.new(model_class: Section).call(object, {}, context)
      end

      def plan(id:)
        Decidim::Plans::PlanFinderHelper.new(model_class: Plan).call(object, { id: id }, context)
      end
    end

    class PlanListHelper < Decidim::Core::ComponentListBase
      def query_scope
        super.published.not_hidden
      end

      def call(_component, args, _ctx)
        results = super

        results = add_default_states(results, args.fetch(:filter, {}))

        # Default order to avoid PostgreSQL random ordering.
        results.order(:id)
      end

      private

      # If no states are defined, show only non-withdrawn plans.
      def add_default_states(results, filter)
        if filter[:state].is_a?(Hash)
          states_filter = filter[:state]
          return results if states_filter[:state].is_a?(Array) && states_filter[:state].any?
        end

        results.except_withdrawn
      end
    end

    class PlanFinderHelper < Decidim::Core::ComponentFinderBase
      def query_scope
        super.published.not_hidden
      end
    end

    class SectionListHelper < Decidim::Core::ComponentListBase
      def call(_component, _args, _ctx)
        # Default order to avoid PostgreSQL random ordering.
        super.order(:position)
      end
    end
  end
end
