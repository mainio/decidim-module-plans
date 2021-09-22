# frozen_string_literal: true

module Decidim
  module Plans
    module CellContentHelper
      def category_section
        @category_section ||= first_section_with_type("field_category")
      end

      def category_content
        return unless category_section

        @category_content ||= content_for(category_section)
      end

      def category
        return unless category_content

        @category ||= Decidim::Category.find_by(id: category_content.body["category_id"])
      end

      def address_section
        @address_section ||= first_section_with_type("field_map_point")
      end

      def address_content
        return unless address_section

        @address_content ||= content_for(address_section)
      end

      def area_scope_section
        @area_scope_section ||= first_section_with_type("field_area_scope")
      end

      def area_scope_content
        return unless area_scope_section

        @area_scope_content ||= content_for(area_scope_section)
      end

      def area_scope
        return unless area_scope_content

        @area_scope ||= Decidim::Scope.find_by(id: area_scope_content.body["scope_id"])
      end

      def area_scopes_parent
        return unless area_scope_section

        @area_scopes_parent ||= begin
          parent_id = area_scope_section.settings["area_scope_parent"].to_i
          return unless parent_id

          Decidim::Scope.find_by(id: parent_id)
        end
      end

      # Checks if the resource should show its scope or not.
      # resource - the resource to analize
      #
      # Returns boolean.
      def has_visible_area_scope?
        parent_scope = area_scopes_parent
        return false unless parent_scope

        area_scope.present? && parent_scope != area_scope
      end

      def has_category?
        category.present?
      end

      def has_category_or_area_scope?
        category.present? || has_visible_area_scope?
      end

      def content_for(section)
        plan.contents.find_by(section: section)
      end

      def first_section_with_type(type)
        Decidim::Plans::Section.order(:position).find_by(
          component: current_component,
          section_type: type
        )
      end

      def section_with_handle(handle)
        Decidim::Plans::Section.order(:position).find_by(
          component: current_component,
          handle: handle
        )
      end
    end
  end
end
