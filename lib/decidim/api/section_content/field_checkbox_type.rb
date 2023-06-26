# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldCheckboxType < GraphQL::Schema::Object
        graphql_name "PlanCheckboxFieldContent"
        description "A plan content for checkbox field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, GraphQL::Types::Boolean, description: "The answer response.", null: false

        def value
          return false unless object.body

          object.body["checked"] ? true : false
        end
      end
    end
  end
end
