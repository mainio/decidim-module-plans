# frozen_string_literal: true

module Decidim
  module Plans
    class ContentType < GraphQL::Schema::Object
      graphql_name "Content"
      description "A plan content"

      implements Decidim::Plans::TimestampsInterface

      field :id, ID, null: false
      field :title, Decidim::Core::TranslatedFieldType, description: "What is the title text for this section (i.e. the section body).", null: false
      field :body, Decidim::Core::TranslatedFieldType, description: "The text answer response option.", null: false
    end
  end
end
