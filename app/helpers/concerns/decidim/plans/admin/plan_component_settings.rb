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
              case attribute.type
              when :plan_layout
                layouts = Decidim::Plans.layouts.all.map do |manifest|
                  [t(manifest.public_name_key), manifest.name]
                end

                state_select = form.select(
                  name,
                  layouts,
                  options.merge(extra_options_for_type(name))
                )

                state_select + plans_settings_js
              when :plan_state
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

            # rubocop:disable Rails/HelperInstanceVariable
            def plans_settings_js
              return "" if @plan_settings_included

              @plan_settings_included = true
              append_javascript_pack_tag("decidim_plans_admin_component_settings")
            end
            # rubocop:enable Rails/HelperInstanceVariable
          end
        end
      end
    end
  end
end
