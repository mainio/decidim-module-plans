# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldTaxonomyCell < Decidim::Plans::SectionEditCell
        include ActionView::Helpers::FormOptionsHelper

        delegate :current_component, to: :controller

        def show
          return if taxonomy_filters.empty?

          render
        end

        private

        def field_id
          "taxonomy_#{section.id}"
        end

        def taxonomy_filters
          @taxonomy_filters ||= begin
            filter_ids = current_component.settings.taxonomy_filters.map(&:to_i)
            Decidim::TaxonomyFilter.where(id: filter_ids)
          end
        end

        def grouped_filter_taxonomies(filter)
          groups = {}

          filter.taxonomies.each do |id, node|
            groups[id] = { taxonomy: node[:taxonomy], children: node[:children] }
          end

          groups
        end
      end
    end
  end
end
