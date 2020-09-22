# frozen_string_literal: true

module Decidim
  module Plans
    # A plan section is a record that stores the question data and order of
    # items that the users need to fill for each plan. The actual contents of
    # the plans are stored in the Decidim::Plans::Content records.
    class Section < Plans::ApplicationRecord
      include Decidim::HasComponent

      def self.types
        @types ||= %w(
          field_text_multiline
          field_text
          field_number
          field_checkbox
          field_scope
          field_area_scope
          field_category
          field_map_point
          field_attachments
          field_image_attachments
          content
        )
      end

      def self.attachment_input_types
        @attachment_input_types ||= %w(single multi)
      end

      validates :section_type, inclusion: { in: self.types }
    end
  end
end
