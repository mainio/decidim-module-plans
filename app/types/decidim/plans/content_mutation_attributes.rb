# frozen_string_literal: true

module Decidim
  module Plans
    class ContentMutationAttributes < GraphQL::Schema::InputObject
      graphql_name "PlanContentMutationAttributes"
      description "A plan content attributes"

      argument :id, ID, required: false
      argument :section_id, ID, required: false

      def prepare
        raise GraphQL::ExecutionError, "Must specify exactly one of id or sectionId" if (id && section_id) || (!id && !section_id)

        # Find the content object or create a new one and map it to the given
        # section.
        content =
          if id
            find_content
          else
            Decidim::Plans::Content.new(section: find_section)
          end

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

      private

      def find_content
        cnt = Decidim::Plans::Content.find_by(id: id)
        raise GraphQL::ExecutionError, "Invalid id provided for content: #{id}" unless cnt

        cnt
      end

      def find_section
        section = Decidim::Plans::Section.find_by(id: section_id)
        raise GraphQL::ExecutionError, "Invalid sectionId provided for content: #{section_id}" unless section

        section
      end
    end
  end
end
