# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class FieldAttachmentsType < GraphQL::Schema::Object
        graphql_name "PlanAttachmentsFieldContent"
        description "A plan content for attachments field"

        implements Decidim::Plans::Api::ContentInterface

        field :value, [Decidim::Core::AttachmentType], description: "The selected attachments.", null: true

        def value
          return nil unless object.body["attachment_ids"].is_a?(Array)

          object.body["attachment_ids"].map do |id|
            Decidim::Attachment.find_by(id: id)
          end.compact
        end
      end
    end
  end
end
