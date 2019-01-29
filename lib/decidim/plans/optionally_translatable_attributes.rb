# frozen_string_literal: true

module Decidim
  module Plans
    module OptionallyTranslatableAttributes
      extend ActiveSupport::Concern
      include TranslatableAttributes

      class_methods do
        def optionally_translatable_attribute(name, type, *options)
          @translatable_attributes ||= []
          @translatable_attributes << name
          translatable_attribute(name, type, *options)
        end

        def translatable_attributes
          @translatable_attributes
        end
      end

      def before_validation
        handle_multilingual_fields
      end

      private

      def handle_multilingual_fields
        return if component.settings.multilingual_answers?

        self.class.translatable_attributes.each do |name|
          attr_src_name = "#{name}_#{current_locale}"
          value = public_send(attr_src_name)

          # Set the same value for all locales as given for the source locale
          available_locales.each do |loc|
            attr_name = "#{name}_#{loc}"
            public_send("#{attr_name}=", value)
          end
        end
      end

      # The current locale for the user. Available as a helper for the views.
      #
      # Returns a String.
      def current_locale
        @current_locale ||= I18n.locale.to_s
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
