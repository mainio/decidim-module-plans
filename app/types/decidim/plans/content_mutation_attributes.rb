# frozen_string_literal: true

module Decidim
  module Plans
    class ContentMutationAttributes < GraphQL::Schema::InputObject
      graphql_name "PlanContentMutationAttributes"
      description "A plan content attributes"

      argument :id, ID, required: true

      def prepare
        content = Decidim::Plans::Content.find(id)
        type = content.section.section_type
        type = "field_text" if type == "field_text_multiline"

        /^field_([a-z_]+)/.match(type) do |match|
          field = match[1]
          if respond_to?(field)
            content.body = public_send(field).to_h

            return content
          end
        end

        nil
      end
    end
  end
end
