# frozen_string_literal: true

module Decidim
  module Plans
    class CoauthorshipsCell < Decidim::CoauthorshipsCell
      def show
        if authorable?
          cell "decidim/plans/author", presenter_for_author(model), extra_classes.merge(has_actions: has_actions?, from: model)
        else
          cell(
            "decidim/plans/collapsible_authors",
            presenters_for_identities(model),
            cell_name: "decidim/plans/author",
            cell_options: extra_classes,
            size: size,
            from: model,
            has_actions: has_actions?
          )
        end
      end
    end
  end
end
