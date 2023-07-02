# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for category field type.
      class Scope < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["scope_id"].blank?

          ref = "plan_content_#{section.id}"
          query.joins(
            Arel.sql(
              <<~SQL.squish
                LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{query.table_name}.id
                AND #{ref}.decidim_section_id = #{section.id}
              SQL
            )
          ).where(Arel.sql("#{ref}.body->>'scope_id' =?"), params["scope_id"])
        end

        def search_params_for(_section)
          {
            scope_id: ""
          }
        end

        def save!(plan)
          plan.scope = Decidim::Scope.find_by(id: scope_id) if scope_id

          super
        end

        private

        def scope_id
          return unless body_attribute

          body_attribute[:scope_id]
        end
      end
    end
  end
end
