# frozen_string_literal: true

module Decidim
  module Plans
    # This type represents a map point type.
    class MapPointType < GraphQL::Schema::Object
      graphql_name "MapPointType"
      description "A map point with coordinates and address"

      field :address, String, description: "The address of the point.", null: true
      field :latitude, Float, description: "The latitude coordinate of the point.", null: false
      field :longitude, Float, description: "The logintude coordinate of the point.", null: false
    end
  end
end
