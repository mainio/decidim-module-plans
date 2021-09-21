# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldNumberCell < Decidim::Plans::SectionEditCell
        private

        def currency_type?
          section.section_type == "field_currency"
        end

        def field_options
          base = super
          base_class = base[:class] || ""

          base.merge(class: "#{base_class} input-group-field".strip, help_text: nil)
        end

        def help_text
          return if tooltip_help?

          @help_text ||= model.help
        end

        def currency_unit_after?
          # See Rails currency formatting:
          # %u = unit
          # %n = number
          format = I18n.t("number.currency.format") || { format: "%u%n" }
          format[:format].scan(/%u|%n/).index("%u") == 1
        end
      end
    end
  end
end
