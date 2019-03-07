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
        rich_content(translated_attribute(content.body))
      end
    end
  end
end
