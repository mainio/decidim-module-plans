# app/helpers/decidim/plans/admin/sections_helper.rb
# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      module SectionsHelper
        def scopes_picker_field(form, name, root: nil, options: {}, html_options: {})
          scopes_root = root || current_participatory_space.scope
          return unless scopes_root

          form.select(name, scopes_options(scopes_root), options, html_options)
        end

        private

        def scopes_options(parent, prefix = "")
          opts = []
          parent.children.order(Arel.sql("code, name->>'#{I18n.locale}'")).each do |scope|
            opts << ["#{prefix}#{translated_attribute(scope.name)}", scope.id]
            opts.concat(scopes_options(scope, "#{prefix}#{translated_attribute(scope.name)} / "))
          end
          opts
        end
      end
    end
  end
end