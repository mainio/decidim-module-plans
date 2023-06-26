# frozen_string_literal: true

module Decidim
  module Plans
    class SectionCell < Decidim::ViewModel
      private

      def current_component
        context[:current_component]
      end

      def settings
        section.settings
      end

      def section
        model.section
      end

      def current_locale
        I18n.locale.to_s
      end

      def routes_proxy
        @routes_proxy ||= EngineRouter.main_proxy(current_component)
      end
    end
  end
end
