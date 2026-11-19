# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTextCell < Decidim::Plans::SectionEditCell
        private

        def field_options(name = :body)
          base = super.merge(label: false)
          return base unless display_character_counter?

          base.merge(
            maxlength: answer_length,
            # Disable the core character counter with a hidden dummy element
            "data-remaining-characters": "#plans-dummy-counter-#{section.id}"
          )
        end

        def display_character_counter?
          answer_length.positive?
        end

        def answer_length
          model.section.settings["answer_length"].to_i
        end
      end
    end
  end
end
