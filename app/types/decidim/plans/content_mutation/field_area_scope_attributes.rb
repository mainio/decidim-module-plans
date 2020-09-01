# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldAreaScopeAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanAreaScopeFieldAttributes"
        description "A plan attributes for area scope field"

        argument :id, ID, required: true

        def to_h
          scope = Decidim::Scope.find(id)

          { "scope_id" => scope.id }
        end
      end
    end
  end
end
