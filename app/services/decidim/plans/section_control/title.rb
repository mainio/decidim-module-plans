# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for field_title field type.
      class Title < Base
        def save!(plan)
          plan.title = form.body

          true
        end
      end
    end
  end
end
