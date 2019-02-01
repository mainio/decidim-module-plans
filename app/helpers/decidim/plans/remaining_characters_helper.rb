# frozen_string_literal: true

module Decidim
  module Plans
    module RemainingCharactersHelper
      def remaining_characters(attribute, num_characters)
        return unless block_given?

        field_opts = {}
        if num_characters.positive?
          remaining_characters_id = "#{attribute}_remaining_characters"
          field_opts = {
            maxlength: num_characters,
            data: {
              remaining_characters: "##{remaining_characters_id}"
            }
          }
        end

        field = capture do
          yield field_opts
        end
        chars_elem = render(
          "decidim/plans/shared/remaining_characters_container",
          remaining_characters_id: remaining_characters_id
        )

        field + chars_elem
      end
    end
  end
end
