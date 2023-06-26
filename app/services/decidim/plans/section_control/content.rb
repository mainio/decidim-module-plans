# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for content section type.
      class Content < Base
        # Content records don't need to be saved as they don't contain any user
        # data.
        def save!(plan); end
      end
    end
  end
end
