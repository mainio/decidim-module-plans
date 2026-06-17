# frozen_string_literal: true

module Decidim
  module Plans
    # The ContentType class creates the user readable content for each field.
    # More detailed value information is available thorugh ContentSubject.
    class ContentType < GraphQL::Schema::Object
      graphql_name "PlanContent"
      description "A plan content in user readable format"

      implements Decidim::Core::TimestampsInterface

      field :body, Decidim::Plans::ContentBodyFieldType, description: "The text answer response option.", null: true
      field :id, GraphQL::Types::ID, description: "ID", null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "What is the title text for this section (i.e. the section body).", null: false

      # rubocop:disable GraphQL/ResolverMethodLength
      def body
        case object.section.section_type
        when "field_checkbox"
          checkbox_body
        when "field_area_scope"
          area_scope_body
        when "field_category"
          category_body
        when "field_taxonomy"
          taxonomy_body
        when "field_map_point"
          map_point_body
        when "field_text", "field_text_multiline"
          object.body
        end
      end
      # rubocop:enable GraphQL/ResolverMethodLength

      private

      # TODO: Move these to field specific presenter classes.
      def checkbox_body
        current_organization.available_locales.index_with { object.body["checked"] }
      end

      def area_scope_body
        scope = Decidim::Scope.find_by(id: object.body["scope_id"])
        current_organization.available_locales.index_with { scope&.name&.[](locale) }
      end

      def category_body
        category = Decidim::Category.find_by(id: object.body["category_id"])
        current_organization.available_locales.index_with { category&.name&.[](locale) }
      end

      def map_point_body
        current_organization.available_locales.index_with { object.body["address"] }
      end

      def current_organization
        context[:current_organization]
      end
    end
  end
end
