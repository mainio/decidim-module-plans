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
            javascript_include_tag "decidim/plans/map"
          end
        end
      end
    end
  end
end
