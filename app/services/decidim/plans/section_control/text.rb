# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for content section type.
      class Text < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["text"].blank?

          ref = Arel.sql("plan_content_#{section.id}")
          locale = Arel.sql(I18n.locale.to_s)
          query.joins(
            "LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{Arel.sql(query.table_name)}.id
            AND #{ref}.decidim_section_id = #{Arel.sql(section.id.to_s)}"
          ).where("#{ref}.body->>'#{locale}' ILIKE ?", "%#{params["text"]}%")
        end
      end
    end
  end
end
