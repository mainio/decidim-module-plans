# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTextCell < Decidim::Plans::SectionEditCell
        private

        def field_options
          base = super
          return base if model.section.settings["answer_length"].to_i < 1

          base.merge(label: false, maxlength: model.section.settings["answer_length"])
        end
      end
    end
  end
end
