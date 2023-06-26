# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldTagsType < GraphQL::Schema::Object
        graphql_name "PlanTagsFieldContent"
        description "A plan content for tags field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, [Decidim::Tags::TagType], description: "The selected tags.", null: true

        def value
          return nil unless object.body
          return nil unless object.body["tag_ids"].is_a?(Array)

          Decidim::Tags::Tag.where(id: object.body["tag_ids"])
        end
      end
    end
  end
end
