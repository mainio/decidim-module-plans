# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldNumberType < GraphQL::Schema::Object
        graphql_name "PlanNumberFieldContent"
        description "A plan content for number field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, GraphQL::Types::Int, description: "The answer response.", null: true

        def value
          return nil unless object.body

          object.body["value"]
        end
      end
    end
  end
end
