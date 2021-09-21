# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldCurrencyAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanCurrencyFieldAttributes"
        description "A plan attributes for currency field"

        argument :value, Integer, description: "The answer response", required: true

        def to_h
          { "value" => value }
        end
      end
    end
  end
end
