# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTextMultilineCell < Decidim::Plans::SectionTypeEdit::FieldTextCell
        def field_label_classes
          classes = []
          classes << "flex--sbc flex--column-reverse flex-medium--row" if show_tooltip? || help_text.present?
          classes <<
            if show_tooltip?
              "with-tooltip"
            elsif help_text.present?
              "with-help"
            end
          return if classes.blank?

          classes.join(" ")
        end

        private

        def field_id(name)
          "contents_#{model.section.id}_#{name}"
        end
      end
    end
  end
end
