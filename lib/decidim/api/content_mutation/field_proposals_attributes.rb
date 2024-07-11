# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldProposalsAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanProposalsFieldAttributes"
        description "A plan attributes for linked proposals field"

        argument :ids, [GraphQL::Types::ID], required: true

        def to_h
          existing_ids = ids.map do |id|
            proposal = Decidim::Proposals::Proposal.find_by(id:)
            proposal&.id
          end

          { "proposal_ids" => existing_ids.compact }
        end
      end
    end
  end
end
