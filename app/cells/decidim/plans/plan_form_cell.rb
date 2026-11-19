# frozen_string_literal: true

module Decidim
  module Plans
    class PlanFormCell < Decidim::ViewModel
      include Decidim::Plans::ApplicationHelper
      include ActionView::Helpers::FormOptionsHelper
      include ::Decidim::LayoutHelper
      include Decidim::Plans::CellRouteOptions

      delegate(
        :current_user,
        :user_signed_in?,
        :user_public?,
        :component_settings,
        :current_component,
        :snippets,
        to: :controller
      )

      delegate :new_plan_path, to: :routes_proxy

      def contents_edit
        render :contents_edit
      end

      def sign_in_box
        render :sign_in_box
      end

      def profile_publicity_box
        render :profile_publicity_box
      end

      private

      def preview_mode?
        !user_signed_in?
      end

      def display_save_as_draft?
        plan.blank? || plan.draft?
      end

      def display_discard?
        plan && plan.persisted? && plan.draft?
      end

      def form
        model
      end

      def plan
        context[:plan]
      end

      def plan_path(plan, options = {})
        return "#" unless plan

        Decidim::ResourceLocatorPresenter.new(plan).path(options)
      end

      def object
        form.object
      end

      def current_locale
        I18n.locale.to_s
      end

      def routes_proxy
        @routes_proxy ||= Decidim::EngineRouter.main_proxy(current_component)
      end
    end
  end
end
