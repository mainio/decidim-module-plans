# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the category field type.
      #
      # NOTE: Categories were removed from Decidim core in v0.30 in favor of
      # taxonomies. This form is kept as legacy/dead code for components that
      # may still hold historical category data, but should not be used for
      # new sections. Guards are in place so it degrades gracefully when
      # `current_component` no longer responds to `categories`.
      class FieldCategoryForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_category_field

        attribute :category_id, Integer
        attribute :sub_category_id, Integer

        validates :category_id, presence: true, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          plan = model.plan
          return unless plan
          return unless plan.component
          return unless categories

          model_category = categories.find_by(
            id: model.body["category_id"]
          )
          return unless model_category

          if model_category.parent_id
            self.category_id = model_category.parent_id
            self.sub_category_id = model_category.id
          else
            self.category_id = model_category.id
          end
        end

        # Finds the Category from either sub_category_id or category_id. If
        # sub-category is defined, that will be used.
        #
        # Returns a Decidim::Category or nil if categories are unavailable.
        def category
          return unless categories

          cat_id = sub_category_id.presence || category_id
          return if cat_id.blank?

          @category ||= categories.find_by(id: cat_id)
        end

        def body
          { category_id: category&.id }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          self.category_id = data["category_id"] || data[:category_id]
        end

        private

        # Returns the categories association if the component still supports
        # it, otherwise nil. Categories were removed from core components in
        # Decidim v0.30.
        def categories
          return unless current_component.respond_to?(:categories)

          current_component.categories
        end
      end
    end
  end
end
