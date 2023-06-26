# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class ContentAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanSectionContentAttributes"
        description "A plan section content attributes"
      end
    end
  end
end
