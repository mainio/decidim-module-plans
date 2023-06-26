# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldAreaScopeCell < Decidim::Plans::SectionTypeEdit::FieldScopeCell
        private

        def scopes_root
          @scopes_root ||= begin
            Decidim::Scope.find_by(id: settings["area_scope_parent"]) ||
              current_participatory_space.scope
          end
        end
      end
    end
  end
end
