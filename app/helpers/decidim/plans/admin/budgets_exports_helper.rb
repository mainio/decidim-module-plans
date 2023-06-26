# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      module BudgetsExportsHelper
        def has_scope?
          sections.where(section_type: "field_scope").any?
        end

        def has_area_scope?
          sections.where(section_type: "field_area_scope").any?
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
