# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldMapPointAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanMapPointFieldAttributes"
        description "A plan attributes for area scope field"

        argument :geocode, Boolean, required: false, default_value: false
        argument :address, String, required: true
        argument :latitude, Float, required: false
        argument :longitude, Float, required: false

        def to_h
          if geocode && geocoder
            coordinates = geocoder.coordinates(address)
            {
              "address" => address,
              "latitude" => coordinates.first,
              "longitude" => coordinates.last
            }
          else
            {
              "address" => address,
              "latitude" => latitude,
              "longitude" => longitude
            }
          end
        end

        private

        def geocoder
          return unless Decidim::Map.available?(:geocoding)

          @geocoder ||= Decidim::Map.geocoding(
            organization: context[:current_organization]
          )
        end
      end
    end
  end
end
