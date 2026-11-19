# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTitleCell < Decidim::Plans::SectionTypeEdit::FieldTextCell
        private

        def field_id(name)
          "contents_#{model.section.id}_#{name}"
        end
      end
    end
  end
end
