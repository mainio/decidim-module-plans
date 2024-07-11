# frozen_string_literal: true

module Decidim
  module Plans
    module DiffRenderer
      class Base < Decidim::BaseDiffRenderer
        include ::Decidim::ApplicationHelper

        def initialize(version, locale)
          @version = version
          @display_locale = locale
        end

        # Renders the diff of the given changeset. Doesn't take into account
        # translatable fields.
        #
        # Returns a Hash, where keys are the fields that have changed and values
        # are an array, the first element being the previous value and the last
        # being the new one.
        def diff
          version.changeset.inject({}) do |diff, (attribute, values)|
            attribute = attribute.to_sym
            type = attribute_types[attribute]

            if type.blank?
              diff
            elsif [:i18n, :i18n_html].include?(type)
              parse_i18n_changeset(attribute, values, type, diff)
            else
              parse_changeset(attribute, values, type, diff)
            end
          end
        end

        protected

        attr_reader :version, :display_locale

        def i18n_scope
          "activemodel.attributes"
        end

        def generate_label(attribute)
          I18n.t(attribute, scope: i18n_scope)
        end

        def generate_i18n_label(attribute, locale)
          label = I18n.t(attribute, scope: i18n_scope)
          return label if display_locale

          "#{label} (#{locale_name(locale)})"
        end

        def locale_name(locale)
          if I18n.available_locales.include?(locale.to_sym)
            I18n.t("locale.name", locale:)
          else
            locale
          end
        end

        def translated_attribute(attribute, locale = nil)
          return "" if attribute.nil?
          return attribute unless attribute.is_a?(Hash)

          attribute = attribute.dup.stringify_keys
          locale ||= I18n.locale.to_s

          attribute[locale].presence ||
            attribute[I18n.locale.to_s].presence ||
            attribute[attribute.keys.first].presence ||
            ""
        end

        def parse_changeset(attribute, values, type, diff)
          values = render_values(values, type)

          diff.update(
            attribute => {
              type:,
              label: generate_label(attribute),
              old_value: values[0],
              new_value: values[1]
            }
          )
        end

        def parse_i18n_changeset(attribute, values, _type, diff)
          values.last.each_key do |locale, _value|
            next if display_locale && display_locale != locale

            first_value = values.first.try(:[], locale) if values.first.is_a? Hash
            last_value = values.last.try(:[], locale) if values.last.is_a? Hash
            next if first_value == last_value

            attribute_locale = "#{attribute}_#{locale}".to_sym
            diff.update(
              attribute_locale => {
                type: :string,
                label: generate_i18n_label(attribute, locale),
                old_value: first_value,
                new_value: last_value
              }
            )
          end
          diff
        end

        # Clears the values and makes them user friendly.
        #
        # values - an array of two objects to be rendered
        # type - the type of the object
        def render_values(values, type)
          [
            render_value(values[0], type),
            render_value(values[1], type)
          ]
        end

        # Renders the given value in a user-friendly way based on the value
        # class.
        #
        # value - an object to be rendered
        # type - the type of the object
        def render_value(value, type)
          return "" if value.blank?

          case type
          when :date
            l value, format: :long
          when :percentage
            number_to_percentage value, precision: 2
          when :translatable
            value.to_s
          else
            value
          end
        end
      end
    end
  end
end
