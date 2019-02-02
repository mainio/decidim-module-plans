# frozen_string_literal: true

module Decidim
  module Plans
    module DiffRenderer
      class Plan < Base
        protected

        def i18n_scope
          "activemodel.attributes.plan"
        end

        # Lists which attributes will be diffable and how
        # they should be rendered.
        def attribute_types
          {
            title: :i18n,
            decidim_scope_id: :scope,
            state: :string
          }
        end
      end
    end
  end
end
