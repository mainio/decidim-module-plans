# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders the plan card for an instance of a Plan
    # the default size is the Medium Card (:m)
    class PlanCell < Decidim::ViewModel
      include PlanCellsHelper
      include Cell::ViewModel::Partial
      include Messaging::ConversationHelper

      delegate :user_signed_in?, to: :parent_controller

      def show
        cell card_size, model, options
      end

      private

      def current_user
        context[:current_user]
      end

      def card_size
        "decidim/plans/plan_g"
      end

      def resource_path
        resource_locator(model).path + request_params_query
      end

      def current_participatory_space
        model.component.participatory_space
      end

      def current_component
        model.component
      end

      def component_name
        translated_attribute model.component.name
      end

      def component_type_name
        model.class.model_name.human
      end

      def participatory_space_name
        translated_attribute current_participatory_space.title
      end

      def participatory_space_type_name
        translated_attribute current_participatory_space.model_name.human
      end
    end
  end
end
