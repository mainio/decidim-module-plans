# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders the "notification" for the plan which is visible at the
    # top of the plan page displaying its answer and status (accepted, rejected,
    # evaluating).
    class PlanNotificationCell < Decidim::CardMCell
      # include PlanCellsHelper
      # include Decidim::Plans::CellContentHelper
      include ActionView::Helpers::NumberHelper

      delegate :current_component, :current_user, to: :controller

      def show
        return unless model.answered?

        render
      end

      private

      def status_class
        if model.accepted?
          "success"
        elsif model.rejected?
          "alert"
        else
          "warning"
        end
      end

      def icon_key
        if model.accepted?
          "circle-check"
        elsif model.rejected?
          "warning"
        else
          "flag"
        end
      end

      def title
        if model.accepted?
          t(".accepted.title")
        elsif model.rejected?
          t(".rejected.title")
        else
          t(".evaluating.title")
        end
      end

      def description
        answer_text
      end

      def answer_text
        @answer_text ||= translated_attribute(model.answer)
      end

      def has_answer_text?
        strip_tags(answer_text).strip.present?
      end
    end
  end
end
