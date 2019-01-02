# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # Custom helpers, scoped to the forms engine.
      #
      module ApplicationHelper
        def tabs_id_for_section(section)
          "section_#{section.to_param}"
        end
      end
    end
  end
end
