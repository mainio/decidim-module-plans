# frozen_string_literal: true

module Decidim
  module Plans
    # This cell renders:
    # - The taxonomies of a resource shown with the translated name
    # - The assigned tags from the plans
    #
    # The context `resource` must be present example use inside another `cell`:
    #   <%= cell("decidim/plans/tags", model, context: {resource: model}) %>
    #
    class TagsCell < Decidim::TagsCell
      def show
        render if taxonomies.any? || taggings?
      end

      private

      def taggings?
        model.tags.any?
      end

      def taggings_path
        resource_locator(model).index(filter: { tag_id: model.tags.map { |tag| tag.id.to_s } })
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
