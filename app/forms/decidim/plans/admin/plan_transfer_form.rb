# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class PlanTransferForm < Decidim::Form
        mimic :transfer

        attribute :target_component_id, Integer
        attribute :section_mapping, Hash
        attribute :taxonomy_mapping, Hash

        validate :target_component_valid, if: :target_component_id
        validate :sections_mapped, if: :target_component
        validate :taxonomies_valid, if: :taxonomy_mapping_needed?

        def source_sections
          @source_sections ||= Section.where(component: current_component).order(:position)
        end

        def target_sections
          return Section.none unless target_component

          @target_sections ||= Section.where(component: target_component).order(:position)
        end

        def target_component
          @target_component ||= available_components.find { |c| c.id == target_component_id }
        end

        def available_components
          @available_components ||= Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(current_organization).flat_map do |space|
              space.components.where(manifest_name: "plans").where.not(id: current_component.id).to_a
            end
          end
        end

        def mapping
          @mapping ||= section_mapping.to_h { |source, target| [source.to_s.to_i, target.to_s.to_i] }
        end

        def same_space?
          target_component.present? &&
            target_component.participatory_space == current_component.participatory_space
        end

        def target_taxonomies
          return Decidim::Taxonomy.none unless target_component

          @target_taxonomies ||= Decidim::Taxonomy.where(id: target_taxonomy_ids)
        end

        def source_taxonomies
          @source_taxonomies ||= Plan.where(component: current_component).includes(:taxonomies).flat_map(&:taxonomies).uniq
        end

        def taxonomy_mapping_needed?
          target_component.present? && !same_space? && target_taxonomies.any? && source_taxonomies.any?
        end

        def taxonomy_map
          @taxonomy_map ||= taxonomy_mapping.to_h do |source, target|
            [source.to_s.to_i, target.to_s.presence&.to_i]
          end
        end

        private

        def target_component_valid
          errors.add(:target_component_id, :invalid) if target_component.blank?
        end

        def sections_mapped
          if target_sections.count != source_sections.count
            errors.add(:target_component_id, :section_count_mismatch)
          elsif !valid_mapping?
            errors.add(:section_mapping, :invalid)
          end
        end

        def valid_mapping?
          mapping.keys.sort == source_sections.pluck(:id).sort &&
            mapping.values.sort == target_sections.pluck(:id).sort &&
            types_compatible?
        end

        def types_compatible?
          types = (source_sections.to_a + target_sections.to_a).index_by(&:id).transform_values(&:section_type)
          mapping.all? { |source_id, target_id| types[source_id] == types[target_id] }
        end

        def taxonomies_valid
          allowed = target_taxonomies.pluck(:id)
          errors.add(:taxonomy_mapping, :invalid) unless taxonomy_map.values.compact.all? { |id| allowed.include?(id) }
        end

        def target_taxonomy_ids
          filter_ids = Array(target_component.settings.taxonomy_filters)

          Decidim::TaxonomyFilter.where(id: filter_ids).flat_map(&:filter_taxonomy_ids)
        end
      end
    end
  end
end
