# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldImageAttachmentsType < GraphQL::Schema::Object
        graphql_name "PlanImageAttachmentsFieldContent"
        description "A plan content for image attachments field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, [Decidim::Core::AttachmentType], description: "The selected attachments.", null: true

        def value
          return nil unless object.body
          return nil unless object.body["attachment_ids"].is_a?(Array)

          object.body["attachment_ids"].map do |id|
            Decidim::Attachment.find_by(id: id)
          end.compact
        end
      end
    end
  end
end
