# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTitleCell < Decidim::Plans::SectionEditCell
        private

        def field_options
          base = super
          return base if model.section.settings["answer_length"].to_i < 1

          base.merge(
            label: false,
            maxlength: model.section.settings["answer_length"],
            # Disable the core character counter with a hidden dummy element
            "data-remaining-characters": "#plans-dummy-counter-#{section.id}"
          )
        end
      end
    end
  end
end
