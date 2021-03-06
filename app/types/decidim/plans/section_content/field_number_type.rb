# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldNumberType < GraphQL::Schema::Object
        graphql_name "PlanNumberFieldContent"
        description "A plan content for number field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Integer, description: "The answer response.", null: true

        def value
          object.body["value"]
        end
      end
    end
  end
end
