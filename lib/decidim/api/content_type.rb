# frozen_string_literal: true

module Decidim
  module Plans
    # The ContentType class creates the user readable content for each field.
    # More detailed value information is available thorugh ContentSubject.
    class ContentType < GraphQL::Schema::Object
      graphql_name "PlanContent"
      description "A plan content in user readable format"

      implements Decidim::Core::TimestampsInterface

      field :id, GraphQL::Types::ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "What is the title text for this section (i.e. the section body).", null: false
      field :body, Decidim::Plans::ContentBodyFieldType, description: "The text answer response option.", null: true

      def body
        # TODO: Move these to field specific presenter classes.
        case object.section.section_type
        when "field_checkbox"
          current_organization.available_locales.inject({}) do |result, locale|
            result.update(locale => object.body["checked"])
          end
        when "field_area_scope"
          scope = Decidim::Scope.find_by(id: object.body["scope_id"])
          current_organization.available_locales.inject({}) do |result, locale|
            if scope
              result.update(locale => scope.name[locale])
            else
              result.update(locale => nil)
            end
          end
        when "field_category"
          category = Decidim::Category.find_by(id: object.body["category_id"])
          current_organization.available_locales.inject({}) do |result, locale|
            if category
              result.update(locale => category.name[locale])
            else
              result.update(locale => nil)
            end
          end
        when "field_map_point"
          current_organization.available_locales.inject({}) do |result, locale|
            result.update(locale => object.body["address"])
          end
        when "field_text", "field_text_multiline"
          object.body
        end
      end

      private

      def current_organization
        context[:current_organization]
      end
    end
  end
end
