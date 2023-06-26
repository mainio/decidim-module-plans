# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldCategoryType < GraphQL::Schema::Object
        graphql_name "PlanCategoryFieldContent"
        description "A plan content for category field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, Decidim::Core::CategoryType, description: "The selected category.", null: true

        def value
          return nil unless object.body

          Decidim::Category.find_by(id: object.body["category_id"])
        end
      end
    end
  end
end
