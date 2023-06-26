# frozen_string_literal: true

module Decidim
  module Plans
    # The content record is the actual content for each plan section for a
    # single plan.
    class Content < Plans::ApplicationRecord
      include Decidim::Plans::Traceable

      self.table_name = "decidim_plans_plan_contents"

      scope :visible_in_form, -> { joins(:section).where(decidim_plans_sections: { visible_form: true }) }
      scope :visible_in_view, -> { joins(:section).where(decidim_plans_sections: { visible_view: true }) }
      scope :with_section_type, ->(type) { joins(:section).where(decidim_plans_sections: { section_type: type }) }

      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: "decidim_plan_id"
      belongs_to :section, class_name: "Decidim::Plans::Section", foreign_key: "decidim_section_id"
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"

      def title
        section.body
      end

      def section_type_manifest
        section&.section_type_manifest
      end
    end
  end
end
