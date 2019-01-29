# frozen_string_literal: true

module Decidim
  module Plans
    module LocaleAware
      extend ActiveSupport::Concern

      class_methods do
        def current_locale
          I18n.locale.to_s
        end
      end

      private

      # The current locale for the user. Available as a helper for the views.
      #
      # Returns a String.
      def current_locale
        @current_locale ||= self.class.current_locale
      end

      # The available locales in the application. Available as a helper for the
      # views.
      #
      # Returns an Array of Strings.
      def available_locales
        @available_locales ||= (current_organization || Decidim).public_send(:available_locales)
      end
    end
  end
end
