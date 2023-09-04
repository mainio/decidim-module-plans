# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders a plan with its M-size card.
    class PlanLCell < Decidim::Plans::PlanMCell
      def card_classes
        classes = super
        classes = classes.split unless classes.is_a?(Array)
        (classes + ["card--full"]).join(" ")
      end

      private

      def resource_image_variant
        :thumbnail_box
      end

      def category_image_variant
        :card_box
      end
    end
  end
end
