# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldCurrencyType < GraphQL::Schema::Object
        include ActionView::Helpers::NumberHelper

        graphql_name "PlanCurrencyFieldContent"
        description "A plan content for currency field"

        implements Decidim::Plans::Api::ContentInterface

        field :text, GraphQL::Types::String, description: "The answer response as formatted text.", null: true
        field :unit, GraphQL::Types::String, description: "The currency unit.", null: false
        field :value, GraphQL::Types::Int, description: "The answer response.", null: true

        def value
          return nil unless object.body

          object.body["value"]
        end

        def unit
          Decidim.currency_unit
        end

        def text
          return nil unless value

          precision = 0.zero? ? 0 : 2
          number_to_currency(
            value,
            unit:,
            precision:,
            locale: I18n.locale
          )
        end
      end
    end
  end
end
