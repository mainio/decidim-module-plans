# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldMapPointCell < Decidim::Plans::SectionDisplayCell
        private

        def address
          @address ||= model.body["address"]
        end

        def latitude
          @latitude ||= model.body["latitude"]
        end

        def longitude
          @longitude ||= model.body["longitude"]
        end
      end
    end
  end
end
