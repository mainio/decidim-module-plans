# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class DuplicateSections < Decidim::Command
        def initialize(old_component, new_component)
          @old_component = old_component
          @new_component = new_component
        end

        def call
          # component scopes it to organization
          # rubocop:disable Decidim/OrganizationScopedFinder
          Decidim::Plans::Section.where(component: @old_component).find_each do |section|
            # rubocop:enable Decidim/OrganizationScopedFinder
            new_section = section.dup
            new_section.component = @new_component
            new_section.save!
          end

          broadcast(:ok)
        end
      end
    end
  end
end
