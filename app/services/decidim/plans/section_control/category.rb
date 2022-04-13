# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for category field type.
      class Category < Base
        def search(query, section, params)
          return query if params.blank?
          return query if params["category_id"].blank?

          ref = Arel.sql("plan_content_#{section.id}")
          ref_cats = Arel.sql("plan_categories_#{section.id}")
          query.joins(
            "LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{Arel.sql(query.table_name)}.id
            AND #{ref}.decidim_section_id = #{Arel.sql(section.id.to_s)}"
          ).joins(
            "LEFT JOIN decidim_categories AS #{ref_cats} ON #{ref_cats}.id = CAST(coalesce(#{ref}.body->>'category_id', '0') AS integer)"
          ).where("#{ref_cats}.id =? OR #{ref_cats}.parent_id =?", params["category_id"], params["category_id"])
        end

        def search_params_for(_section)
          {
            category_id: ""
          }
        end

        def save!(plan)
          # Fetch the category for the categorization to be created correctly.
          # It is not enough to set decidim_category_id here because of the
          # categorization association.
          plan.category = Decidim::Category.find_by(id: category_id) if category_id

          super
        end

        private

        def category_id
          return unless body_attribute

          body_attribute[:category_id]
        end
      end
    end
  end
end
