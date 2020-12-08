# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldCheckboxCell < Decidim::Plans::SectionEditCell
        private

        def show_input?
          model.id.blank?
        end
      end
    end
  end
end
