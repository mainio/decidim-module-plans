# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldCategoryAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanCategoryFieldAttributes"
        description "A plan attributes for category field"

        argument :id, ID, required: true

        def to_h
          category = Decidim::Category.find(id)

          { "category_id" => category.id }
        end
      end
    end
  end
end
