# frozen_string_literal: true

module Decidim
  module Plans
    # A plan section is a record that stores the question data and order of
    # items that the users need to fill for each plan. The actual contents of
    # the plans are stored in the Decidim::Plans::Content records.
    class Section < Plans::ApplicationRecord
      include Decidim::HasComponent

      scope :visible_in_form, -> { where(visible_form: true) }
      scope :visible_in_view, -> { where(visible_view: true) }
      scope :visible_in_api, -> { where(visible_api: true) }

      def self.types
        @types ||= Decidim::Plans.section_types.all.map do |type|
          type.name.to_s
        end
      end

      def self.attachment_input_types
        @attachment_input_types ||= %w(single multi)
      end

      validates :section_type, inclusion: { in: types }

      def section_type_manifest
        Decidim::Plans.section_types.find(section_type)
      end
    end
  end
end
