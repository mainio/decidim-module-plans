# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # Exposes the scopes details so the dynamic scope fields can be created.
      class ScopesController < Decidim::ApplicationController
        include Decidim::TranslatableAttributes

        skip_before_action :store_current_location

        def index
          enforce_permission_to :pick, :scope

          render json: scopes_data
        end

        private

        def scopes_data
          scopes.includes(:scope_type).map do |scope|
            {
              id: scope.id,
              name: translated_attribute(scope.name),
              type: {
                id: scope.scope_type.id,
                name: translated_attribute(scope.scope_type.name)
              }
            }
          end
        end

        def scopes
          @scopes ||= root&.children || current_organization.scopes.top_level
        end

        def root
          return if params[:root].blank?

          @root ||= current_organization.scopes.find(params[:root])
        end
      end
    end
  end
end
