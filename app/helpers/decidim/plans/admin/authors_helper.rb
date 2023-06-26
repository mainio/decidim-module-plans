# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      module AuthorsHelper
        def destroy_author_path_for(plan, author)
          return plan_organization_author_path(plan, author) if author.is_a?(Decidim::Organization)

          plan_author_path(plan, author)
        end
      end
    end
  end
end
