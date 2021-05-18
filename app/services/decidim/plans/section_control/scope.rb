# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for category field type.
      class Scope < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["scope_id"].blank?

          ref = Arel.sql("plan_content_#{section.id}")
          query.joins(
            "LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{Arel.sql(query.table_name)}.id
            AND #{ref}.decidim_section_id = #{Arel.sql(section.id.to_s)}"
          ).where("#{ref}.body->>'scope_id' =?", params["scope_id"])
        end

        def search_params_for(_section)
          {
            scope_id: ""
          }
        end
      end
    end
  end
end
