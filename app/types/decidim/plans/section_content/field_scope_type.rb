# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldScopeType < GraphQL::Schema::Object
        graphql_name "PlanScopeFieldContent"
        description "A plan content for scope field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Decidim::Core::ScopeApiType, description: "The selected scope.", null: true

        def value
          Decidim::Scope.find_by(id: object.body["scope_id"])
        end
      end
    end
  end
end
