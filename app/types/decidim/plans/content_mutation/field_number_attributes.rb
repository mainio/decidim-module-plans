# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldNumberAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanNumberFieldAttributes"
        description "A plan attributes for number field"

        argument :value, Integer, description: "The answer response", required: true

        def to_h
          { "value" => value }
        end
      end
    end
  end
end
