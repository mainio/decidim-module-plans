# frozen_string_literal: true

module Decidim
  module Plans
    # Exposes Plan versions so users can see how a Plan
    # has been updated through time.
    class VersionsController < Decidim::Plans::ApplicationController
      helper Decidim::TraceabilityHelper
      helper_method :current_version, :item_versions, :content_versions, :item

      def show
        raise ActionController::RoutingError, "Not Found" if item.blank? || current_version.blank?
      end

      private

      def item
        @item ||= Plan.where(component: current_component).find_by(id: params[:plan_id])
      end

      def current_version
        return nil if params[:id].to_i < 1

        @current_version ||= item.versions[params[:id].to_i - 1]
      end

      def item_versions
        return [] if current_version.transaction_id.nil?

        # There may be multiple updates on the item during the same transaction
        Decidim::Plans::PaperTrail::Version.where(
          transaction_id: current_version.transaction_id,
          item_type: "Decidim::Plans::Plan"
        ).order(:created_at)
      end

      def content_versions
        return [] if current_version.transaction_id.nil?

        @content_versions ||= item.sections.map do |section|
          content = item.contents.find_by(section:)
          next unless content

          content.versions.find_by(
            transaction_id: current_version.transaction_id
          )
        end.compact
      end
    end
  end
end
