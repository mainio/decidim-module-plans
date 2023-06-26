# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class ContentType < GraphQL::Schema::Object
        graphql_name "PlanSectionContent"
        description "A plan section content (no user defined content)"

        implements Decidim::Plans::Api::ContentInterface
      end
    end
  end
end
