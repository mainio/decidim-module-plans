# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for content section type.
      class Text < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["text"].blank?

          ref = "plan_content_#{section.id}"
          locale = I18n.locale.to_s
          query.joins(
            Arel.sql(
              <<~SQL.squish
                LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{query.table_name}.id
                AND #{ref}.decidim_section_id = #{section.id}
              SQL
            )
          ).where(Arel.sql("#{ref}.body->>'#{locale}' ILIKE ?"), "%#{params["text"]}%")
        end
      end
    end
  end
end
