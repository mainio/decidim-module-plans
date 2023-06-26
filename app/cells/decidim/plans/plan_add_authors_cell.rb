# frozen_string_literal: true

module Decidim
  module Plans
    class PlanAddAuthorsCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include ERB::Util
      include Decidim::FormFactory

      delegate :allowed_to?, :current_component, :current_user, to: :controller

      private

      def plan
        model
      end

      # :public or :admin depending where the modal is shown in
      def mode
        options[:mode] || :public
      end

      def form_url
        return routes_proxy.plan_authors_path(plan) if mode == :admin

        routes_proxy.add_authors_plan_path(plan)
      end

      def add_author_form
        @add_author_form ||= form(AddAuthorToPlanForm).from_params({})
      end

      def current_locale
        I18n.locale.to_s
      end

      def routes_proxy
        return ::Decidim::EngineRouter.admin_proxy(plan.component) if mode == :admin

        ::Decidim::EngineRouter.main_proxy(plan.component)
      end

      def decidim_plans
        @decidim_plans ||= Decidim::Plans::Engine.routes.url_helpers
      end

      def decidim_plans_admin
        @decidim_plans_admin ||= Decidim::Plans::AdminEngine.routes.url_helpers
      end
    end
  end
end
