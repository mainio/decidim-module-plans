# frozen_string_literal: true

module Decidim
  module Plans
    # A plan section is a record that stores the question data and order of
    # items that the users need to fill for each plan. The actual contents of
    # the plans are stored in the Decidim::Plans::Content records.
    class Section < Plans::ApplicationRecord
      include Decidim::HasComponent
    end
  end
end
