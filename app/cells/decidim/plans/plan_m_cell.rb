# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders a plan with its M-size card.
    class PlanMCell < Decidim::CardMCell
      include PlanCellsHelper

      def badge
        render if has_badge?
      end

      private

      def title
        present(model).title
      end

      def body
        present(model).body
      end

      def has_state?
        model.published?
      end

      def has_badge?
        answered? || withdrawn?
      end

      def has_link_to_resource?
        model.published?
      end

      def description
        model_body = strip_tags(body)

        if options[:full_description]
          model_body.gsub(/\n/, "<br>")
        else
          truncate(model_body, length: 100)
        end
      end

      def badge_classes
        return super unless options[:full_badge]

        state_classes.concat(["label", "plan-status"]).join(" ")
      end

      def statuses
        return [:comments_count] if model.draft?

        [:creation_date, :follow, :comments_count]
      end

      def creation_date_status
        l(model.published_at.to_date, format: :decidim_short)
      end
    end
  end
end
