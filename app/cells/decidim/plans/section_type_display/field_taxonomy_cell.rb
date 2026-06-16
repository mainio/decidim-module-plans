# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldTaxonomyCell < Decidim::Plans::SectionDisplayCell

        def show
          return if taxonomies.empty?

          render
        end

        private

        def taxonomy_ids
          Array(body["taxonomy_ids"]).map(&:to_i).reject(&:zero?)
        end

        def taxonomies
          @taxonomies ||= Decidim::Taxonomy.where(id: taxonomy_ids)
        end
      end
    end
  end
end