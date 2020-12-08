# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldCheckboxCell < Decidim::Plans::SectionEditCell
        private

        def field_options
          base = super
          base.delete(:help_text) # Causes the display of the checkbox to break
          base
        end

        def show_input?
          model.id.blank?
        end
      end
    end
  end
end
