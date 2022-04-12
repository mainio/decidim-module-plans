# frozen_string_literal: true

module Decidim
  module Plans
    # This type represents a content body field. This is similar to the core's
    # TranslatedFieldType but takes into account the specialities with the plan
    # contents (i.e. not every field is translated).
    class ContentBodyFieldType < GraphQL::Schema::Object
      graphql_name "ContentBodyField"
      description "A content body field"

      field :locales, [String], description: "Lists all the locales in which this content is available in.", null: true
      field :translations, [Decidim::Core::LocalizedStringType], description: "All the localized strings for this content.", null: false do
        argument :locales, [String], description: "A list of locales to scope the translations to.", required: false
      end
      field :translation, GraphQL::Types::String, description: "Returns a single translation given a locale.", null: true do
        argument :locale, GraphQL::Types::String, description: "A locale to search for", required: true
      end

      def locales
        current_organization.available_locales
      end

      def translations(locales: nil)
        translations = object.stringify_keys
        translations = translations.slice(*locales) if locales

        translations.map { |locale, text| OpenStruct.new(locale: locale, text: text) }
      end

      def translation(locale:)
        translations = object.stringify_keys
        translations[locale]
      end

      private

      def current_organization
        context[:current_organization]
      end
    end
  end
end
