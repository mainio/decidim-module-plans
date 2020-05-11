# frozen_string_literal: true

module Decidim
  module Plans
    # A service to move plans from one component to another. The moving process
    # requires mapping the contents to sections of another component because of
    # which this requires special functionality.
    class PlanMover
      attr_reader :to_component

      def initialize(to_component)
        @to_component = to_component
      end

      # Allows more sections to exist in the to_component than in the component
      # where the plan is copied from.
      def allow_section_mismatch!
        @allow_section_mismatch = true
      end

      def allow_section_mismatch?
        @allow_section_mismatch
      end

      def all_sections_mapped?(from_component, sections_map)
        Plans::Section.where(
          component: from_component
        ).order(:position).pluck(:id).all? do |sect_id|
          sections_map.has_key?(sect_id)
        end
      end

      def move_plan(plan, maps = {})
        sections_map = maps[:sections] || generate_sections_map(plan.component)
        category_map = maps[:category] || generate_category_map(plan.component)

        unless all_sections_mapped?(plan.component, sections_map)
          raise(
            InvalidSectionMappingError,
            "All target component sections need to have a mapped section in the source component."
          )
        end

        plan.transaction do
          plan.contents.each do |content|
            content.update!(
              decidim_section_id: sections_map[content.section.id]
            )
          end

          category = nil
          category = category_map[plan.category.id] if plan.category

          plan.update!(
            component: to_component,
            category: category
          )
        end
      end

      private

      class InvalidSectionMappingError < StandardError; end
      class SectionCountMismatchError < StandardError; end

      def generate_sections_map(from_component)
        from_sections = Plans::Section.where(component: from_component).order(:position)
        to_sections = Plans::Section.where(component: to_component).order(:position)

        if allow_section_mismatch?
          if to_sections.count < from_sections.count
            raise(
              SectionCountMismatchError,
              "Cannot move to a component with less sections than in the source component."
            )
          end
        elsif to_sections.count != from_sections.count
          raise(
            SectionCountMismatchError,
            "Cannot move to a component with different number of sections than in the source component."
          )
        end

        from_sections.map.with_index do |from_section, ind|
          [from_section.id, to_sections[ind].id]
        end.to_h
      end

      def generate_category_map(from_component)
        from_space = from_component.participatory_space
        to_space = to_component.participatory_space
        organization = from_space.organization
        locale = organization.default_locale

        Decidim::Category.where(participatory_space: from_space).map do |cat|
          cat_name = cat.name[locale].strip

          corresponding = Decidim::Category.find_by(
            "decidim_participatory_space_type =? AND decidim_participatory_space_id =? AND TRIM(name->>'#{locale}') =?",
            to_space.class.to_s,
            to_space.id,
            cat_name
          )

          [cat.id, corresponding]
        end.to_h
      end
    end
  end
end
