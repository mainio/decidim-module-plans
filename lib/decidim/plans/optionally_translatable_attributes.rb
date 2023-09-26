# frozen_string_literal: true

module Decidim
  module Plans
    module OptionallyTranslatableAttributes
      extend ActiveSupport::Concern
      include LocaleAware
      include TranslatableAttributes

      class_methods do
        def optionally_translatable_attribute(name, type, *options)
          @translatable_attributes ||= []
          @translatable_attributes << name
          translatable_attribute(name, type, *options)
        end

        def optionally_translatable_validate_presence(attribute, options = {})
          if_conditional_proc = conditional_proc(options[:if])
          multilingual_proc = proc { |record|
            record.component.settings.multilingual_answers?
          }

          multilingual_options = options.dup
          localized_options = options.dup

          multilingual_options[:if] = proc { |record|
            multilingual_proc.call(record) && if_conditional_proc.call(record)
          }

          multilingual_options[:translatable_presence] = true
          localized_options[:presence] = true

          validates attribute, multilingual_options

          I18n.available_locales.each do |locale|
            opts = localized_options.dup
            opts[:if] = proc { |record|
              current_locale.to_sym == locale.to_sym && !multilingual_proc.call(record) && if_conditional_proc.call(record)
            }
            localized_attribute = "#{attribute}_#{locale}".to_sym
            validates localized_attribute, opts
          end
        end

        def translatable_attributes
          @translatable_attributes
        end

        def conditional_proc(condition)
          return proc { true } if condition.nil?

          if condition.is_a?(String) || condition.is_a?(Symbol)
            return proc { |record|
              record.send(condition)
            }
          end

          proc { |record| condition.call(record) }
        end
      end

      def before_validation
        handle_multilingual_fields
      end

      private

      def multilingual?
        component.settings.multilingual_answers?
      end

      def handle_multilingual_fields
        return if multilingual?
        return unless self.class.translatable_attributes

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
    end
  end
end
