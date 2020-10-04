# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldTextAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanTextFieldAttributes"
        description "A plan attributes for text field"

        argument :value, GraphQL::Types::JSON, description: "The answer response", required: true

        def to_h
          value
        end
      end
    end
  end
end
