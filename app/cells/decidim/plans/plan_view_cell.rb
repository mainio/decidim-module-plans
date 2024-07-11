# frozen_string_literal: true

module Decidim
  module Plans
    class PlanViewCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include ERB::Util
      include Decidim::ApplicationHelper # For presenter
      include Decidim::LayoutHelper # For the icon helper
      include Decidim::FormFactory
      include Decidim::TooltipHelper
      include Decidim::MetaTagsHelper
      include Decidim::Plans::LinksHelper
      include Decidim::Plans::CellContentHelper
      include Decidim::Feedback::FeedbackHelper
      include SocialShareButton::Helper
      include Decidim::Plans::Engine.routes.url_helpers

      delegate :allowed_to?, :current_user, to: :controller
      delegate :plans_path, :plan_url, :plan_path, :plan_versions_path, to: :routes_proxy

      def contents
        render :contents
      end

      def collaborator_requests
        return unless allowed_to?(:edit, :plan, plan:)
        return unless plan.requesters.any?

        render :collaborator_requests
      end

      def plan_notification(data = {})
        context = data[:context] || {}
        data = data.merge(
          context: context.merge(current_component:)
        )

        cell(
          layout_manifest.notification_layout,
          plan,
          data
        )
      end

      private

      def plan
        model
      end

      def current_component
        context[:current_component] || controller.current_component
      end

      def trigger_feedback?
        options[:trigger_feedback]
      end

      def preview_mode?
        options[:preview]
      end

      def show_actions?
        !preview_mode?
      end

      def show_controls?
        !preview_mode? && allowed_to?(:edit, :plan, plan:)
      end

      def has_map_position?
        return false unless address_content
        return false unless address_content.body

        address_content.body["latitude"] && address_content.body["longitude"]
      end

      def plan_map_link(options = {})
        return "#" unless address_content
        return "#" unless address_content.body

        @map_utility_static ||= Decidim::Map.static(
          organization: current_component.participatory_space.organization
        )
        return "#" unless @map_utility_static

        @map_utility_static.link(
          latitude: address_content.body["latitude"],
          longitude: address_content.body["longitude"],
          options:
        )
      end

      def access_request_pending?
        return false unless current_user

        plan.collaborator_requests.exists?(user: current_user)
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

      def image_section
        @image_section ||= first_section_with_type("field_image_attachments")
      end

      def image_content
        @image_content ||= content_for(image_section)
      end

      def plan_image
        return unless image_content
        return unless image_content.body
        return if image_content.body["attachment_ids"].blank?

        @plan_image ||= Decidim::Attachment.find_by(
          id: image_content.body["attachment_ids"].first
        )
      end

      def share_description
        present(plan).body
      end

      def share_image_url
        plan_image&.url || organization_share_image_url
      end

      def organization_share_image_url
        @organization_share_image_url ||= begin
          container = Decidim::ContentBlock.published.find_by(
            organization: current_organization,
            scope_name: :homepage,
            manifest_name: :hero
          ).try(:images_container)
          container.attached_uploader(:background_image).url if container && container.background_image && container.background_image.attached?
        end
      end

      def twitter_handle
        current_component.participatory_space.organization.twitter_handler
      end

      def current_locale
        I18n.locale.to_s
      end

      def layout_manifest
        @layout_manifest ||= Decidim::Plans.layouts.find(current_component.settings.layout)
      end

      def routes_proxy
        @routes_proxy ||= EngineRouter.main_proxy(current_component)
      end
    end
  end
end
