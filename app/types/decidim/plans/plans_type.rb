# frozen_string_literal: true

module Decidim
  module Plans
    class PlansType < GraphQL::Schema::Object
      graphql_name "Plans"
      description "A plans component of a participatory space."

      implements Decidim::Core::ComponentInterface

      field :plans, PlanType.connection_type, null: true

      field :sections, SectionType.connection_type, null: true

      field(:plan, PlanType, null: true) do
        argument :id, ID, required: true
      end

      def plans
        PlansTypeHelper.base_scope(object).includes(:component)
      end

      def sections
        SectionsTypeHelper.base_scope(object).includes(:component)
      end

      def plan(id:)
        PlansTypeHelper.base_scope(object).find_by(id: id)
      end
    end

    module PlansTypeHelper
      def self.base_scope(component)
        Plan
          .where(component: component)
          .published
      end
    end

    module SectionsTypeHelper
      def self.base_scope(component)
        Section
          .where(component: component)
          .order(:position)
      end
    end
  end
end
