# frozen_string_literal: true

module Decidim
  module Plans
    module RemainingCharactersHelper
      def remaining_characters(attribute, num_characters)
        return unless block_given?
        return unless num_characters.is_a?(Integer)

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
        chars_elem = content_tag(
          :p,
          nil,
          id: remaining_characters_id,
          class: "form-extra help-text",
          data: {
            remaining_characters_messages: {
              one: t("decidim.components.add_comment_form.remaining_characters_1", count: "%count%"),
              many: t("decidim.components.add_comment_form.remaining_characters", count: "%count%")
            }
          }
        )

        field + chars_elem
      end
    end
  end
end
