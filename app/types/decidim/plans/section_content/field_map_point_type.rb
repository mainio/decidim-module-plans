# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldMapPointType < GraphQL::Schema::Object
        graphql_name "PlanMapPointFieldContent"
        description "A plan content for area scope field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Decidim::Plans::MapPointType, method: :body, description: "The defined map point.", null: true
      end
    end
  end
end
