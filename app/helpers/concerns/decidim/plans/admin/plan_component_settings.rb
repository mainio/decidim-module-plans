# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Plans
    module Admin
      module PlanComponentSettings
        extend ActiveSupport::Concern

        included do
          unless method_defined?(:settings_attribute_input_orig_plans)
            alias_method :settings_attribute_input_orig_plans, :settings_attribute_input

            def settings_attribute_input(form, attribute, name, i18n_scope, options = {})
              if attribute.type == :plan_layout
                layouts = Decidim::Plans.layouts.all.map do |manifest|
                  [t(manifest.public_name_key), manifest.name]
                end

                state_select = form.select(
                  name,
                  layouts,
                  options.merge(extra_options_for_type(name))
                )

                state_select + plans_settings_js
              elsif attribute.type == :plan_state
                state_select = form.select(
                  name,
                  [
                    [t("decidim.components.plans.settings.global.default_answer_none"), nil],
                    [t("decidim.plans.answers.accepted"), "accepted"],
                    [t("decidim.plans.answers.rejected"), "rejected"],
                    [t("decidim.plans.answers.evaluating"), "evaluating"]
                  ],
                  options.merge(extra_options_for_type(name))
                )

                state_select + plans_settings_js
              else
                settings_attribute_input_orig_plans(form, attribute, name, i18n_scope, options)
              end
            end

            def plans_settings_js
              return "" if @plan_settings_included

              @plan_settings_included = true
              javascript_include_tag("decidim/plans/admin/component_settings")
            end
          end
        end
      end
    end
  end
end
