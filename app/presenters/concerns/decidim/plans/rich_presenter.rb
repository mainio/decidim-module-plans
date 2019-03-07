# frozen_string_literal: true

module Decidim
  module Plans
    module RichPresenter
      extend ActiveSupport::Concern
      include ActionView::Helpers::TextHelper

      def plain_content(content)
        sanitize(content, tags: [])
      end

      def rich_content(content)
        simple_format(sanitize(content, tags: allowed_rich_tags), wrapper_tag: nil)
      end

      protected

      def allowed_rich_tags
        ["strong", "em", "b", "i"]
      end
    end
  end
end
