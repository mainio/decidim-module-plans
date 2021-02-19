# frozen_string_literal: true

module Decidim
  module Plans
    # The ContentSubject class creates the actual detailed value information for
    # each field based on their types.
    class ContentSubject < GraphQL::Schema::Union
      graphql_name "PlanContentSubject"
      description "A plan content detailed values"

      possible_types(
        Decidim::Plans::SectionContent::ContentType,
        Decidim::Plans::SectionContent::FieldAttachmentsType,
        Decidim::Plans::SectionContent::FieldAreaScopeType,
        Decidim::Plans::SectionContent::FieldCategoryType,
        Decidim::Plans::SectionContent::FieldCheckboxType,
        Decidim::Plans::SectionContent::FieldImageAttachmentsType,
        Decidim::Plans::SectionContent::FieldMapPointType,
        Decidim::Plans::SectionContent::FieldScopeType,
        Decidim::Plans::SectionContent::FieldTextType,
        Decidim::Plans::SectionContent::FieldNumberType
      )

      def self.resolve_type(object, _context)
        object.section.section_type_manifest.api_type_class || Decidim::Plans::SectionContent::FieldTextType
      end
    end
  end
end
