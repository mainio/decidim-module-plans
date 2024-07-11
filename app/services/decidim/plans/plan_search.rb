# frozen_string_literal: true

module Decidim
  module Plans
    # A service to encapsualte extra logic when searching and filtering plans.
    class PlanSearch < ResourceSearch
      attr_reader :text, :activity, :section

      def build(params)
        @text = params.delete(:search_text)
        @activity = params.delete(:activity)
        @section = params.delete(:section)

        if activity && user
          case activity
          when "my_plans"
            add_scope(:from_author, user)
          when "my_favorites"
            add_scope(:user_favorites, user)
          end
        end

        add_scope(:containing_text, [text, searchable_content_sections, organization.available_locales]) if text.present?
        add_scope(:with_sections_matching, [searchable_sections, section]) if section

        super
      end

      private

      # Finds the sections that can be searched from.
      def searchable_sections
        @searchable_sections ||= Decidim::Plans::Section.where(component:, searchable: true)
      end

      def searchable_content_sections
        @searchable_content_sections ||= searchable_sections.where(
          section_type: [:field_text, :field_text_multiline]
        )
      end
    end
  end
end
