# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldCheckboxCell < Decidim::Plans::SectionDisplayCell
        private

        def value
          model.body["value"]
        end

        def value_text
          value ? t(".yes") : t(".no")
        end
      end
    end
  end
end
