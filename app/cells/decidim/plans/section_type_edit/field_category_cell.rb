# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class FieldCategoryCell < Decidim::Plans::SectionEditCell
        include ActionView::Helpers::FormOptionsHelper

        delegate :current_component, to: :controller
        delegate :categories, to: :current_component

        private

        def field_id
          "category_#{section.id}"
        end

        def top_categories
          @top_categories ||= categories.where(parent_id: nil)
        end

        # Public: Generates a select field with the categories. Only leaf categories can be set as selected.
        #
        # form       - The form object.
        # name       - The name of the field (usually category_id)
        # collection - A collection of categories.
        # options    - An optional Hash with options:
        # - prompt   - An optional String with the text to display as prompt.
        # - disable_parents - A Boolean to disable parent categories. Defaults to `true`.
        # html_options - HTML options for the select
        #
        # Returns a String.
        def categories_select(form, name, collection, options = {}, html_options = {})
          selected = form.object.send(name)
          selected = selected.first if selected.is_a?(Array) && selected.length > 1
          categories = categories_for_select(collection)

          form.select(name, options_for_select(categories), options, html_options)
        end

        # We only want to display the top-level categories.
        def categories_for_select(scope)
          sorted_main_categories = scope.includes(:subcategories).sort_by do |category|
            [category.weight, translated_attribute(category.name, category.participatory_space.organization)]
          end

          sorted_main_categories.flat_map do |category|
            parent = [[translated_attribute(category.name, category.participatory_space.organization), category.id]]

            parent
          end
        end
      end
    end
  end
end
