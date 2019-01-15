# frozen_string_literal: true

module Decidim
  module Plans
    class DiffRenderer
      def initialize(version)
        @version = version
      end

      # Renders the diff of the given changeset. Doesn't take into account translatable fields.
      #
      # Returns a Hash, where keys are the fields that have changed and values are an
      # array, the first element being the previous value and the last being the new one.
      def diff
        version.changeset.inject({}) do |diff, (attribute, values)|
          attribute = attribute.to_sym
          type = attribute_types[attribute]

          if type.blank?
            diff
          else
            parse_changeset(attribute, values, type, diff)
          end
        end
      end

      private

      attr_reader :version

      # Lists which attributes will be diffable and how
      # they should be rendered.
      def attribute_types
        {
          title: :translatable,
          decidim_category_id: :category,
          decidim_scope_id: :scope,
          state: :string
        }
      end

      def parse_changeset(attribute, values, type, diff)
        diff.update(
          attribute => {
            type: type,
            label: I18n.t(attribute, scope: "activemodel.attributes.plan"),
            old_value: values[0],
            new_value: values[1]
          }
        )
      end
    end
  end
end
