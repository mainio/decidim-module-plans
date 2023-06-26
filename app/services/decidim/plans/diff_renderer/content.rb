# frozen_string_literal: true

module Decidim
  module Plans
    module DiffRenderer
      class Content < Base
        protected

        def i18n_scope
          "activemodel.attributes.plan"
        end

        # Lists which attributes will be diffable and how
        # they should be rendered.
        def attribute_types
          {
            body: :i18n
          }
        end

        def generate_label(_attribute)
          translated_attribute(version.item.section.body)
        end

        def generate_i18n_label(_attribute, locale)
          label = translated_attribute(version.item.section.body, locale)
          return label if display_locale

          "#{label} (#{locale_name(locale)})"
        end
      end
    end
  end
end
