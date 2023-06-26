# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldTextType < GraphQL::Schema::Object
        graphql_name "PlanTextFieldContent"
        description "A plan content for text field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Decidim::Core::TranslatedFieldType, method: :body, description: "The answer response.", null: true
      end
    end
  end
end
