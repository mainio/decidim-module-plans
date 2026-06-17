# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      class FieldTaxonomyForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_taxonomy_field

        attribute :taxonomy_ids, [Integer]

        validates :taxonomy_ids, presence: true, if: ->(form) { form.mandatory }

        delegate :current_component, to: :current_component

        def taxonomy_ids=(values)
          super(Array(values).compact.map(&:to_i).reject(&:zero?))
        end

        def map_model(model)
          super
          self.taxonomy_ids = Array(model.body["taxonomy_ids"])
        end

        def body
          { taxonomy_ids: }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          self.taxonomy_ids = Array(data["taxonomy_ids"] || data[:taxonomy_ids])
        end

        def taxonomy_filters
          @taxonomy_filters ||= begin
            filter_ids = current_component.settings.taxonomy_filters.map(&:to_i)
            Decidim::TaxonomyFilter.where(id: filter_ids)
          end
        end
      end
    end
  end
end
