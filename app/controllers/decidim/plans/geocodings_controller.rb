# frozen_string_literal: true

module Decidim
  module Plans
    class GeocodingsController < Decidim::Plans::ApplicationController
      include Decidim::ApplicationHelper

      before_action :ensure_geocoder!, only: [:create, :reverse]

      def create
        enforce_permission_to :create, :plan

        headers["X-Robots-Tag"] = "none"

        coordinates = geocoder.coordinates(params[:address])

        if coordinates.present?
          render json: {
            success: true,
            result: { lat: coordinates.first, lng: coordinates.last }
          }
        else
          render json: {
            success: false,
            result: {}
          }
        end
      end

      def reverse
        enforce_permission_to :create, :plan

        headers["X-Robots-Tag"] = "none"

        address = geocoder.address([params[:lat], params[:lng]])

        if address.present?
          render json: {
            success: true,
            result: { address: address }
          }
        else
          render json: {
            success: false,
            result: {}
          }
        end
      end

      private

      def ensure_geocoder!
        return if geocoder.present?

        # This prevents the action being processed.
        render json: {
          success: false,
          result: {}
        }
      end

      def geocoder
        Decidim::Map.geocoding(organization: current_organization)
      end
    end
  end
end
