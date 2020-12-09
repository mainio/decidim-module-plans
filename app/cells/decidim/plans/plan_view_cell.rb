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
      include SocialShareButton::Helper
      include Decidim::Plans::Engine.routes.url_helpers

      delegate :allowed_to?, :current_component, to: :controller

      private

      def plan
        model
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

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
