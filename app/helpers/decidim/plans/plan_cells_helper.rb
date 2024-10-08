# frozen_string_literal: true

module Decidim
  module Plans
    # Custom helpers, scoped to the plans engine.
    #
    module PlanCellsHelper
      include Decidim::Plans::ApplicationHelper
      include Decidim::Plans::Engine.routes.url_helpers
      include Decidim::LayoutHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::TranslatableAttributes
      include Decidim::CardHelper

      delegate :title, :state, :closed?, :answered?, :withdrawn?, to: :model

      def has_actions?
        false
      end

      def plans_controller?
        context[:controller].instance_of?(::Decidim::Plans::PlansController)
      end

      def index_action?
        context[:controller].action_name == "index"
      end

      def current_settings
        model.component.current_settings
      end

      def component_settings
        model.component.settings
      end

      def current_component
        model.component
      end

      def from_context
        options[:from]
      end

      def badge_name
        humanize_plan_state state
      end
    end
  end
end
