# frozen_string_literal: true

module Decidim
  module Plans
    class SectionType < GraphQL::Schema::Object
      graphql_name "Section"
      description "A plan section"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, null: false
      field :position, Integer, description: "This section's order position", null: false
      field :handle, String, description: "This section's technical handle (readable identifier)", null: false
      field :body, Decidim::Core::TranslatedFieldType, description: "What is the body or question text for this section.", null: false
      field :type, String, method: :section_type, null: false do
        description "The type of this section."
      end
    end
  end
end
