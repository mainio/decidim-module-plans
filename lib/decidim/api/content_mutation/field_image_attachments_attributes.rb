# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldImageAttachmentsAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanImageAttachmentsFieldAttributes"
        description "A plan attributes for image attachments field"

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
