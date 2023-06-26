# frozen_string_literal: true

module Decidim
  module Plans
    module Api
      module ContentInterface
        include GraphQL::Schema::Interface
        include Decidim::Core::TimestampsInterface

        graphql_name "PlanContentInterface"
        description "This interface is implemented by the content types of a plan."

        field :id, ID, null: false
        field :section, SectionType, description: "The section related to this content element.", null: false
        field :title, Decidim::Core::TranslatedFieldType, description: "What is the title text for this section (i.e. the section body).", null: false
      end
    end
  end
end
