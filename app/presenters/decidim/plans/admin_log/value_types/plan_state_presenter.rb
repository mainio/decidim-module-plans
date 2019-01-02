# frozen_string_literal: true

module Decidim
  module Plans
    module AdminLog
      module ValueTypes
        class PlanStatePresenter < Decidim::Log::ValueTypes::DefaultPresenter
          def present
            return unless value
            h.t(value, scope: "decidim.plans.admin.plan_answers.edit", default: value)
          end
        end
      end
    end
  end
end
