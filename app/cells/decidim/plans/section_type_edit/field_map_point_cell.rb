# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldMapPointCell < Decidim::Plans::SectionEditCell
        include Decidim::MapHelper

        delegate :snippets, to: :controller
        delegate :geocoding_path, :reverse_geocoding_path, to: :routes_proxy

        private

        def address_id
          "address_#{section.id}"
        end

        def form_map(map_html_options = {})
          map_options = { type: "plan-form" }

          latitude = settings["map_center_latitude"].to_f
          longitude = settings["map_center_longitude"].to_f
          map_options[:center_coordinates] = [latitude, longitude] if latitude && longitude

          dynamic_map_for(map_options, map_html_options) do
            # These snippets need to be added AFTER the other map scripts have
            # been added which is why they cannot be within the block. Otherwise
            # e.g. the markercluser would not be available when the plans map is
            # loaded.
            unless snippets.any?(:plans_map_scripts)
              snippets.add(:plans_map_scripts, javascript_pack_tag("decidim_plans_map"))
              snippets.add(:foot, snippets.for(:plans_map_scripts))
            end

            # Has to return a string to the dynamic_map_for method.
            ""
          end
        end
      end
    end
  end
end
