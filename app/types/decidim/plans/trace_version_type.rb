# frozen_string_literal: true

module Decidim
  module Plans
    class TraceVersionType < GraphQL::Schema::Object
      graphql_name "TraceVersion"
      description "A trace version type"

      field :id, ID, description: "The ID of the version", null: false
      field :createdAt, Decidim::Core::DateTimeType, method: :created_at, null: true do
        description "The date and time this version was created"
      end
      field :editor, Decidim::Core::AuthorInterface, null: true do
        description "The editor/author of this version"
      end
      field :changeset, GraphQL::Types::JSON, null: true do
        description "Object with the changes in this version"
      end

      delegate :changeset, to: :object

      def editor
        author = Decidim.traceability.version_editor(object)
        author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
      end
    end
  end
end
