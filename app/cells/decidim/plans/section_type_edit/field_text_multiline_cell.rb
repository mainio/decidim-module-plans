# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTextMultilineCell < Decidim::Plans::SectionTypeEdit::FieldTextCell
        def field_info_classes
          classes = %w(field-info)
          classes << "flex--sbc" if show_tooltip? || help_text.present?
          classes <<
            if show_tooltip?
              "with-tooltip"
            elsif help_text.present?
              "with-help"
            end

          classes.join(" ")
        end
      end
    end
  end
end
