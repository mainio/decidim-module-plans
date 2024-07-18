# frozen_string_literal: true

module Decidim
  module Plans
    class CoauthorshipsCell < Decidim::CoauthorshipsCell
      def show
        if authorable?
          cell "decidim/plans/author", presenter_for_author(model), has_actions: has_actions?, from: model
        else
          cell(
            "decidim/plans/collapsible_authors",
            presenters_for_identities(model),
            options.merge(from: model)
          )
        end
      end
    end
  end
end
