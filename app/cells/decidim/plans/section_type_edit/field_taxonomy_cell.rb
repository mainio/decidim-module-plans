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
          filter_ids = filter.taxonomies.keys.map(&:to_i)

          filter.taxonomies.each do |id, node|
            taxonomy = node[:taxonomy]
            parent_id = taxonomy.parent_id

            if parent_id.present? && parent_id != filter.root_taxonomy_id && filter_ids.exclude?(parent_id)
              parent = Decidim::Taxonomy.find_by(id: parent_id)
              next unless parent

              groups[parent.id] ||= { taxonomy: parent, children: {} }
              groups[parent.id][:children][id] = node
            else
              groups[id] ||= { taxonomy: taxonomy, children: {} }
            end
          end
          groups
        end
      end
    end
  end
end