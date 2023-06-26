# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldTagsAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanTagsFieldAttributes"
        description "A plan attributes for tags field"

        argument :ids, [GraphQL::Types::ID], required: true

        def to_h
          existing_ids = ids.map do |id|
            tag = Decidim::Tags::Tag.find_by(id: id)
            tag&.id
          end

          { "tag_ids" => existing_ids.compact }
        end
      end
    end
  end
end
