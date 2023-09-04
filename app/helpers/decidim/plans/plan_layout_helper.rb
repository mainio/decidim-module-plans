# frozen_string_literal: true

module Decidim
  module Plans
    # Helpers that help rendering the plan.
    #
    module PlanLayoutHelper
      def layout_manifest
        @layout_manifest ||= Decidim::Plans.layouts.find(current_component.settings.layout)
      end

      def plan_card_layout
        layout_manifest.card_layout
      end

      def render_plan_index(data = {})
        cell(
          layout_manifest.index_layout,
          current_component,
          data
        )
      end

      def render_plan_form(form, plan, data = {})
        context = data[:context] || {}
        data = data.merge(
          context: context.merge(plan: plan, current_component: current_component)
        )

        cell(
          layout_manifest.form_layout,
          form,
          data
        )
      end

      def render_plan_view(plan, data = {})
        context = data[:context] || {}
        data = data.merge(
          context: context.merge(current_component: current_component)
        )

        cell(
          layout_manifest.view_layout,
          plan,
          data
        )
      end

      def render_plan_notification(plan, data = {})
        context = data[:context] || {}
        data = data.merge(
          context: context.merge(current_component: current_component)
        )

        cell(
          layout_manifest.notification_layout,
          plan,
          data
        )
      end
    end
  end
end
