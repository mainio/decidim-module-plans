# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldAttachmentsAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanAttachmentsFieldAttributes"
        description "A plan attributes for attachments field"

        argument :ids, [GraphQL::Types::ID], required: true

        def to_h
          existing_ids = ids.map do |id|
            attachment = Decidim::Attachment.find_by(id: id)
            attachment&.id
          end

          { "attachment_ids" => existing_ids.compact }
        end
      end
    end
  end
end
