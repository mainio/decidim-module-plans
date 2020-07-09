# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Plans
    module Admin
      module ArrayComponentSettings
        extend ActiveSupport::Concern

        included do
          unless respond_to?(:settings_attribute_input_orig_plans)
            alias_method :settings_attribute_input_orig_plans, :settings_attribute_input

            def settings_attribute_input(form, attribute, name, i18n_scope, options = {})
              if attribute.type == :plan_state
                state_select = form.select(
                  name,
                  [
                    [t("decidim.components.plans.settings.global.default_answer_none"), nil],
                    [t("decidim.plans.answers.accepted"), "accepted"],
                    [t("decidim.plans.answers.rejected"), "rejected"],
                    [t("decidim.plans.answers.evaluating"), "evaluating"]
                  ],
                  options.merge(extra_options_for(name))
                )
                settings_js = javascript_include_tag("decidim/plans/admin/component_settings")

                state_select + settings_js
              else
                settings_attribute_input_orig_plans(form, attribute, name, i18n_scope, options)
              end
            end
          end
        end
      end
    end
  end
end
