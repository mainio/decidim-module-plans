# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldScopeCell < Decidim::Plans::SectionDisplayCell
        def show
          return unless scope

          render
        end

        private

        def scope
          @scope ||= Decidim::Scope.find_by(id: model.body["scope_id"])
        end
      end
    end
  end
end
