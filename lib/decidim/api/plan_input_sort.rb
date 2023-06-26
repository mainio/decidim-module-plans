# frozen_string_literal: true

module Decidim
  module Plans
    class PlanInputSort < Decidim::Core::BaseInputSort
      include Decidim::Core::HasPublishableInputSort
      include Decidim::Core::HasEndorsableInputSort

      graphql_name "PlanSort"
      description "A type used for sorting plans"

      argument :id, GraphQL::Types::String, "Sort by ID, valid values are ASC or DESC", required: false
    end
  end
end
