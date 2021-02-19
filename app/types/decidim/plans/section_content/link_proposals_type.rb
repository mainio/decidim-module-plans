# frozen_string_literal: true

module Decidim
  module Plans
    module SectionContent
      class LinkProposalsType < GraphQL::Schema::Object
        graphql_name "PlanProposalsLinkContent"
        description "A plan content for linked proposals"

        implements Decidim::Plans::Api::ContentInterface

        field :value, [Decidim::Proposals::ProposalType], description: "The linked proposals.", null: true

        def value
          return nil unless object.body
          return nil unless object.body["proposal_ids"].is_a?(Array)

          object.body["proposal_ids"].map do |id|
            Decidim::Proposals::Proposal.find_by(id: id)
          end.compact
        end
      end
    end
  end
end
