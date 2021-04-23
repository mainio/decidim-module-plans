# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for tags field type.
      class Tags < Base
        cattr_accessor :plan_tags_mapped

        def search(query, section, params)
          return query if params.blank?
          return query unless params["tag_ids"].is_a?(Array)
          return query if params["tag_ids"].blank?

          ids = params["tag_ids"].compact.map(&:to_i).join(",")

          ref = Arel.sql("plan_content_#{section.id}")
          query.joins(
            "LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{Arel.sql(query.table_name)}.id
            AND #{ref}.decidim_section_id = #{Arel.sql(section.id)}"
          ).where("#{ref}.body->>'tag_ids' @> ANY(#{ids})")
        end

        def search_params_for(_section)
          {
            tag_ids: ""
          }
        end

        def prepare!(plan)
          self.class.prepare_all(plan)
        end

        def finalize!(plan)
          self.class.finalize_all(plan)
        end

        def self.prepare_all(_plan)
          self.plan_tags_mapped = false

          true
        end

        def self.finalize_all(plan)
          return if plan_tags_mapped

          # Go through all plan sections of this type and take note about all
          # the tags in each section.
          tag_ids = plan.contents.with_section_type(:field_tags).map do |sect|
            sect.body["tag_ids"]
          end.flatten.uniq

          # Add the taggings to the plan object
          tagger = Decidim::Tags::Tagger.new(
            taggable: plan,
            organization: plan.component.organization
          )
          tagger.apply(tag_ids)

          # Mark tags already mapped so that we won't map again during the
          # following sections if there are multiple sections of the same type.
          self.plan_tags_mapped = true

          true
        end
      end
    end
  end
end
