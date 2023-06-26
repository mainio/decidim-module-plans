# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldCategoryCell < Decidim::Plans::SectionDisplayCell
        def show
          return unless category

          render
        end

        private

        def category
          @category ||= Decidim::Category.find_by(id: model.body["category_id"])
        end
      end
    end
  end
end
