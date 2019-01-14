# frozen_string_literal: true

module Decidim
  module Plans
    #
    # Decorator for contents
    #
    class ContentPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include TranslatableAttributes

      def content
        __getobj__
      end

      def title
        translated_attribute(content.title).html_safe
      end

      def body
        translated_attribute(content.body).html_safe
      end
    end
  end
end
