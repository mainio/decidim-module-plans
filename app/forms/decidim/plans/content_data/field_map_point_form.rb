# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the map point field type.
      class FieldMapPointForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_map_point_field

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float

        validates :address, presence: true, if: ->(form) { form.needs_address? }
        validates :address, geocoding: true, if: ->(form) { form.needs_geocoding? }

        def needs_address?
          return false if latitude.present? && longitude.present?

          mandatory
        end

        def needs_geocoding?
          return false if latitude.present? && longitude.present?
          return false if address.blank?
          return false if Decidim.geocoder.blank?

          true
        end

        def map_model(model)
          super

          self.address = model.body["address"]
          self.latitude = model.body["latitude"]
          self.longitude = model.body["longitude"]
        end

        def body
          {
            address:,
            latitude:,
            longitude:
          }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          self.address = data["address"] || data[:address]
          self.latitude = data["latitude"] || data[:latitude]
          self.longitude = data["longitude"] || data[:longitude]
        end
      end
    end
  end
end
