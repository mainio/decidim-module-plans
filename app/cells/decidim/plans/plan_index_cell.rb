# frozen_string_literal: true

module Decidim
  module Plans
    class PlanIndexCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper
      include Cell::ViewModel::Partial
      include Decidim::ResourceHelper
      include Decidim::SanitizeHelper
      include Decidim::LayoutHelper # For the icon helper
      # include Decidim::MapHelper
      include Decidim::FiltersHelper
      include Decidim::OrdersHelper
      include Decidim::CardHelper
      include Decidim::CellsPaginateHelper
      include Decidim::Plans::PlansHelper
      include Decidim::Plans::Engine.routes.url_helpers

      alias component model
      alias current_component model

      delegate :user_signed_in?, :current_user, :allowed_to?, :snippets, to: :controller

      private

      def available_orders
        options[:available_orders]
      end

      def order
        options[:order]
      end

      def order_selector(orders, options = {})
        render partial: "decidim/shared/orders.html", locals: {
          orders:,
          i18n_scope: options[:i18n_scope]
        }
      end

      def plans
        context[:plans]
      end

      def card_cell
        context[:card_cell]
      end

      def geocoded_plans
        context[:geocoded_plans]
      end

      def filter
        context[:filter]
      end

      # Options to filter Plans by activity.
      def activity_filter_values
        [
          ["all", t(".filters.activity.all")],
          ["my_plans", t(".filters.activity.my_plans")],
          ["my_favorites", t(".filters.activity.my_favorites")]
        ]
      end

      def available_tags
        @available_tags ||= Plans::ComponentPlanTags.new(component).query
      end

      def draft_link
        return unless plan_draft
        return unless component.current_settings&.creation_enabled?
        return unless allowed_to?(:edit, :plan, plan: plan_draft)

        @draft_idea_link = edit_plan_path(plan_draft)
      end

      def plan_draft
        return nil unless user_signed_in?

        @plan_draft = Plan.from_all_author_identities(current_user).not_hidden.where(
          component:
        ).find_by(published_at: nil)
      end

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
