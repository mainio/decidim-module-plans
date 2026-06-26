# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      module BudgetsExportsHelper
        def has_taxonomy?
          current_component.settings.taxonomy_filters.any?
        end

        def taxonomy_filters
          filter_ids = current_component.settings.taxonomy_filters.map(&:to_i)
          Decidim::TaxonomyFilter.where(id: filter_ids)
        end

        def content_sections
          sections.where(section_type: %w(field_text field_text_multiline))
        end

        def budget_sections
          sections.where(section_type: %w(field_currency field_number))
        end

        def image_sections
          sections.where(section_type: "field_image_attachments")
        end

        def location_sections
          sections.where(section_type: "field_map_point")
        end

        def section_select_options(sections)
          sections.map { |section| [translated_attribute(section.body), section.id] }
        end
      end
    end
  end
end
