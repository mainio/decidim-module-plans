# frozen_string_literal: true

module Decidim
  module Plans
    # This cell renders:
    # - The category of a resource shown with the translated name (parent)
    # - The scope of a resource shown with the translated name (parent)
    # - The assigned tags from the plans
    #
    # The context `resource` must be present example use inside another `cell`:
    #   <%= cell("decidim/category", model.category, context: {resource: model}) %>
    #
    class TagsCell < Decidim::TagsCell
      def show
        render if category? || scope? || taggings?
      end

      def taggings
        render if taggings?
      end

      private

      def category?
        model.category.present?
      end

      def scope?
        model.scope.present?
      end

      def taggings?
        model.tags.any?
      end

      def link_to_tag(tag)
        link_to tag_name(tag), tag_path(tag)
      end

      def tag_name(tag)
        translated_attribute(tag.name)
      end

      def tag_path(tag)
        resource_locator(model).index(filter: { tag_id: [tag.id] })
      end
    end
  end
end
