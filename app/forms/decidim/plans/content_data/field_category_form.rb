# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the category field type.
      class FieldCategoryForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_category_field

        attribute :category_id, Integer
        attribute :sub_category_id, Integer

        delegate :categories, to: :current_component

        validates :category_id, presence: true, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          plan = model.plan
          return unless plan
          return unless plan.component

          model_category = plan.component.categories.find_by(
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
        # Returns a Decidim::Category
        def category
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
      end
    end
  end
end
