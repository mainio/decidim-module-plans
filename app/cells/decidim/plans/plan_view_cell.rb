# frozen_string_literal: true

module Decidim
  module Plans
    class PlanViewCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include ERB::Util
      include Decidim::ApplicationHelper # For presenter
      include Decidim::LayoutHelper # For the icon helper
      include Decidim::FilterParamsHelper
      include Decidim::FormFactory
      include Decidim::TooltipHelper
      include Decidim::MetaTagsHelper
      include Decidim::Plans::LinksHelper
      include Decidim::Plans::CellContentHelper
      include Decidim::Feedback::FeedbackHelper
      include SocialShareButton::Helper
      include Decidim::Plans::Engine.routes.url_helpers

      delegate :allowed_to?, :current_component, :current_user, to: :controller

      private

      def plan
        model
      end

      def trigger_feedback?
        options[:trigger_feedback]
      end

      def show_controls?
        allowed_to?(:edit, :plan, plan: plan)
      end

      def withdrawable?
        model.withdrawable_by?(current_user)
      end

      def flaggable?
        model.published?
      end

      def report_form
        @report_form ||= form(Decidim::ReportForm).from_params(reason: "spam")
      end

      def request_access_form
        @request_access_form ||= form(RequestAccessToPlanForm).from_params({})
      end

      def accept_request_form
        @accept_request_form ||= form(AcceptAccessToPlanForm).from_params({})
      end

      def reject_request_form
        @reject_request_form ||= form(RejectAccessToPlanForm).from_params({})
      end

      def plan_reason_callout_args
        {
          announcement: {
            title: plan_reason_callout_title,
            body: decidim_sanitize(translated_attribute(plan.answer))
          },
          callout_class: plan_reason_callout_class
        }
      end

      def plan_reason_callout_title
        i18n_key = case plan.state
                   when "evaluating"
                     "plan_in_evaluation_reason"
                   else
                     "plan_#{@idea.state}_reason"
                   end

        t(".answers.#{i18n_key}")
      end

      def idea_reason_callout_class
        case plan.state
        when "accepted"
          "success"
        when "evaluating"
          "warning"
        when "rejected"
          "alert"
        else
          ""
        end
      end

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
