# frozen_string_literal: true

module Decidim
  module Plans
    module RichPresenter
      extend ActiveSupport::Concern
      include ActionView::Helpers::TextHelper

      def rich_content(content)
        simple_format(content, wrapper_tag: nil)
      end
    end
  end
end
