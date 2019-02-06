# frozen_string_literal: true

module Decidim
  module Plans
    module DiffRenderer
      class Component < Base
        protected

        def i18n_scope
          "activemodel.attributes.plan"
        end

        # Lists which attributes will be diffable and how
        # they should be rendered.
        def attribute_types
          {
            decidim_component_id: :component
          }
        end
      end
    end
  end
end
