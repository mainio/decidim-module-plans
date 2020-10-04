# frozen_string_literal: true

module Decidim
  module Plans
    #
    # Decorator for contents
    #
    class ContentPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include TranslatableAttributes
      include Plans::RichPresenter

      def content
        __getobj__
      end

      def title
        plain_content(translated_attribute(content.title))
      end

      def body
        content_body = begin
          if %w(field_text field_text_multiline).include?(content.section.section_type)
            plain_content(translated_attribute(content.body))
          else
            "" # TODO: Other types
          end
        end
        rich_content(translated_attribute(content_body))
      end
    end
  end
end
