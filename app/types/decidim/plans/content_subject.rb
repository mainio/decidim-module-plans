# frozen_string_literal: true

module Decidim
  module Plans
    # The ContentSubject class creates the actual detailed value information for
    # each field based on their types.
    class ContentSubject < GraphQL::Schema::Union
      graphql_name "PlanContentSubject"
      description "A plan content detailed values"

      possible_types(*Decidim::Plans.api_content_types)

      def self.resolve_type(object, _context)
        type_class = "#{object.section.section_type.camelize}Type"
        type_class = "FieldTextType" unless Decidim::Plans::SectionContent.const_defined?(type_class)

        Decidim::Plans::SectionContent.const_get(type_class)
      end
    end
  end
end
