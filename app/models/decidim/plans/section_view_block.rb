# frozen_string_literal: true

module Decidim
  module Plans
    # A plan section view is a record that allows the admin user to customize
    # how the section is displayed. The section can be split into sub-views that
    # display a subset of the data.
    class SectionView < Plans::ApplicationRecord
      include Decidim::HasComponent
    end
  end
end
