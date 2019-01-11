# frozen_string_literal: true

module Decidim
  module Plans
    module AdminLog
      # This class holds the logic to present a `Decidim::Plans::Plan`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PlanPresenter.new(action_log, view_helpers).present
      class PlanPresenter < Decidim::Log::BasePresenter
        private

        def resource_presenter
          @resource_presenter ||= Decidim::Plans::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        def diff_fields_mapping
          {
            state: "Decidim::Plans::AdminLog::ValueTypes::PlanStatePresenter",
            answered_at: :date,
            answer: :i18n
          }
        end

        def action_string
          case action
          when "answer", "create", "update"
            "decidim.plans.admin_log.plan.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.plan"
        end

        def has_diff?
          action == "answer" || super
        end
      end
    end
  end
end
