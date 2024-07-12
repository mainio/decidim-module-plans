# frozen_string_literal: true

module Decidim
  module Plans
    module PlansHelper
      def has_geocoding?
        address_section.present?
      end

      # Serialize a collection of geocoded ideas to be used by the dynamic map
      # component. The serialized list is made for the flat list fetched with
      # `Plan.geocoded_data_for` in order to make the processing faster.
      #
      # geocoded_plans_data - A flat array of the plan data received from `Plan.geocoded_data_for`
      def plans_data_for_map(geocoded_plans_data)
        geocoded_plans_data.map do |data|
          {
            id: data[:id],
            title: translated_attribute(data[:title]),
            body: truncate(translated_attribute(data[:body]), length: 100),
            address: data[:address],
            latitude: data[:latitude],
            longitude: data[:longitude],
            link: plan_path(data[:id])
          }
        end
      end

      def plans_map(geocoded_plans, **options)
        map_options = { type: "plans", markers: geocoded_plans }

        if address_section
          lat = address_section.settings["map_center_latitude"]
          lng = address_section.settings["map_center_longitude"]

          map_options[:center_coordinates] = [lat, lng].map(&:to_f) if lat && lng
        end

        dynamic_map_for(map_options.merge(options)) do
          # These snippets need to be added AFTER the other map scripts have
          # been added which is why they cannot be within the block. Otherwise
          # e.g. the markercluser would not be available when the plans map is
          # loaded.
          unless snippets.any?(:plans_map_scripts)
            snippets.add(:plans_map_scripts, append_javascript_pack_tag("decidim_plans_map"))
            snippets.add(:foot, snippets.for(:plans_map_scripts))
          end

          yield
        end
      end

      # Retrieves the first address section which is used for some settings.
      def address_section
        @address_section ||= Decidim::Plans::Section.order(:position).find_by(
          component: current_component,
          section_type: "field_map_point"
        )
      end
    end
  end
end
