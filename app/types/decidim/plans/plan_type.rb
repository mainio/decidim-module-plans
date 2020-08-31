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

      field :id, ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "This plan's title", null: false
      field :state, String, description: "The answer status in which plan is in", null: true
      field :answer, Decidim::Core::TranslatedFieldType, description: "The answer feedback for the status for this plan", null: true

      field :closedAt, Decidim::Core::DateTimeType, method: :closed_at, null: true do
        description "The date and time this plan was closed"
      end

      field :answeredAt, Decidim::Core::DateTimeType, method: :answered_at, null: true do
        description "The date and time this plan was answered"
      end

      field :publishedAt, Decidim::Core::DateTimeType, method: :published_at, null: true do
        description "The date and time this plan was published"
      end

      field :sections, [SectionType], description: "Sections in this plan.", null: false
      # The contents field is a text representation for each content section in
      # each language.
      field :contents, [Decidim::Plans::ContentType], description: "Contents in this plan.", null: false
      # The values field contains the actual values for each content section
      # which can be different depending on the section type.
      field :values, [Decidim::Plans::ContentSubject], method: :contents, description: "The content values in this plan.", null: false
    end
  end
end
