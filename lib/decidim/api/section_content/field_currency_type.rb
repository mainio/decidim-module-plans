# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldCurrencyType < GraphQL::Schema::Object
        include ActionView::Helpers::NumberHelper

        graphql_name "PlanCurrencyFieldContent"
        description "A plan content for currency field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, GraphQL::Types::Int, description: "The answer response.", null: true
        field :unit, GraphQL::Types::String, description: "The currency unit.", null: false
        field :text, GraphQL::Types::String, description: "The answer response as formatted text.", null: true

        def value
          return nil unless object.body

          object.body["value"]
        end

        def unit
          Decidim.currency_unit
        end

        def text
          return nil unless value

          precision = (value % 1).zero? ? 0 : 2
          number_to_currency(
            value,
            unit: unit,
            precision: precision,
            locale: I18n.locale
          )
        end
      end
    end
  end
end
