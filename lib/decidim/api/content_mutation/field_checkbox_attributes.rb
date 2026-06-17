# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldCheckboxAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanCheckboxFieldAttributes"
        description "A plan attributes for checkbox field"

        argument :value, GraphQL::Types::Boolean, description: "Checkbox value", required: true

        def to_h
          { "checked" => value }
        end
      end
    end
  end
end
