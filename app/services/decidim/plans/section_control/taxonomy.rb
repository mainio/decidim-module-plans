# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      class Taxonomy < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["taxonomy_id"].blank?

          ref = "plan_content_#{section.id}"
          query.joins(
            Arel.sql(
              <<~SQL.squish
                LEFT JOIN decidim_plans_plan_contents AS #{ref}
                  ON #{ref}.decidim_plan_id = #{query.table_name}.id
                  AND #{ref}.decidim_section_id = #{section.id}
              SQL
            )
          ).where(
            Arel.sql("#{ref}.body->'taxonomy_ids' @> ?::jsonb"),
            params["taxonomy_id"].to_json
          )
        end

        def search_params_for(_section)
          { taxonomy_id: "" }
        end

        def save!(plan)
          sync_taxonomizations(plan)

          super
        end

        private

        def taxonomy_ids
          return [] unless body_attribute

          Array(body_attribute[:taxonomy_ids]).map(&:to_i).reject(&:zero?)
        end

        def sync_taxonomizations(plan)
          plan.taxonomizations
              .where.not(taxonomy_id: taxonomy_ids)
              .destroy_all

          taxonomy_ids.each do |taxonomy_id|
            plan.taxonomizations.find_or_create_by(taxonomy_id:)
          end
        end
      end
    end
  end
end
