# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldAreaScopeType < GraphQL::Schema::Object
        graphql_name "PlanAreaScopeFieldContent"
        description "A plan content for area scope field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Decidim::Core::ScopeApiType, description: "The selected area scope.", null: true

        def value
          return nil unless object.body

          Decidim::Scope.find_by(id: object.body["scope_id"])
        end
      end
    end
  end
end
