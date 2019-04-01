# frozen_string_literal: true

module Decidim
  module Plans
    # This query class filters all assemblies given an organization.
    class ComponentPlanTags < Rectify::Query
      def initialize(component)
        @component = component
      end

      def query
        q = Decidim::Plans::Tag.joins(
          "LEFT JOIN decidim_plans_plan_taggings ON decidim_plans_plan_taggings.decidim_plans_tag_id = decidim_plans_tags.id"
        ).joins(
          "LEFT JOIN decidim_plans_plans ON decidim_plans_plans.id = decidim_plans_plan_taggings.decidim_plan_id"
        ).where(
          decidim_plans_tags: {
            decidim_organization_id: @component.organization.id
          },
          decidim_plans_plans: {
            decidim_component_id: @component.id
          }
        ).having("COUNT(decidim_plans_plan_taggings.id) > 0")
        .group("decidim_plans_tags.id")
        .order(Arel.sql("name ->> '#{current_locale}' ASC"))
      end

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
