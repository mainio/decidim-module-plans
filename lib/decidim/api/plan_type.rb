# frozen_string_literal: true

module Decidim
  module Plans
    class PlanType < GraphQL::Schema::Object
      graphql_name "Plan"
      description "A plan"

      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CoauthorableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface
      implements Decidim::Favorites::Api::FavoritesInterface
      implements Decidim::Tags::TagsInterface

      field :id, GraphQL::Types::ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "This plan's title", null: false
      field :state, GraphQL::Types::String, description: "The answer status in which plan is in", null: true
      field :answer, Decidim::Core::TranslatedFieldType, description: "The answer feedback for the status for this plan", null: true

      field :closed_at, Decidim::Core::DateTimeType, null: true do
        description "The date and time this plan was closed"
      end

      field :answered_at, Decidim::Core::DateTimeType, null: true do
        description "The date and time this plan was answered"
      end

      field :published_at, Decidim::Core::DateTimeType, null: true do
        description "The date and time this plan was published"
      end

      field :sections, [SectionType], description: "Sections in this plan.", null: false
      # The contents field is a text representation for each content section in
      # each language.
      field :contents, [Decidim::Plans::ContentType], description: "Contents in this plan.", null: false
      # The values field contains the actual values for each content section
      # which can be different depending on the section type.
      field :values, [Decidim::Plans::ContentSubject], method: :contents, description: "The content values in this plan.", null: false

      def self.add_linked_resources_field
        return unless Decidim::Plans::ResourceLinkSubject.possible_types.any?

        # These are the resources that are linked from the plan to the related
        # object.
        field(
          :linked_resources,
          [Decidim::Plans::ResourceLinkSubject],
          description: "The linked resources for this plan.",
          null: true
        )

        # These are the resources that are linked from other related objects to
        # the plan.
        field(
          :linking_resources,
          [Decidim::Plans::ResourceLinkSubject],
          description: "The linking resources for this plan.",
          null: true
        )
      end

      def sections
        object.sections.visible_in_api
      end

      def contents
        object.contents.joins(:section).where(section: sections).order("decidim_plans_sections.position")
      end

      def linked_resources
        visible_resource_links(object.resource_links_from.map(&:to))
      end

      def linking_resources
        visible_resource_links(object.resource_links_to.map(&:from))
      end

      private

      def visible_resource_links(resources)
        resources = resources.reject do |resource|
          resource.nil? ||
            (resource.respond_to?(:published?) && !resource.published?) ||
            (resource.respond_to?(:hidden?) && resource.hidden?) ||
            (resource.respond_to?(:withdrawn?) && resource.withdrawn?)
        end
        return nil unless resources.any?

        resources
      end
    end
  end
end
