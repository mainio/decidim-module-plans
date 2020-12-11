# frozen_string_literal: true

module Decidim
  module Plans
    # Helpers that help rendering the plan.
    #
    module PlanLayoutHelper
      def layout_manifest
        @layout_manifest ||= Decidim::Plans.layouts.find(current_component.settings.layout)
      end

      def render_plan_form(form, plan)
        cell(
          layout_manifest.form_layout,
          form,
          context: { plan: plan, current_component: current_component }
        )
      end

      def render_plan_view(plan)
        cell(
          layout_manifest.view_layout,
          plan,
          context: { current_component: current_component }
        )
      end
    end
  end
end
