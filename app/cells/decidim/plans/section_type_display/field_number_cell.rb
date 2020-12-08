# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldNumberCell < Decidim::Plans::SectionDisplayCell
        include ActionView::Helpers::NumberHelper

        def show
          return unless number

          render
        end

        private

        def number
          model.body["value"]
        end
      end
    end
  end
end
