# frozen_string_literal: true

module Decidim
  module Plans
    module ContentMutation
      class FieldProposalsAttributes < GraphQL::Schema::InputObject
        graphql_name "PlanProposalsFieldAttributes"
        description "A plan attributes for linked proposals field"

        argument :ids, [ID], required: true

        def to_h
          existing_ids = ids.map do |id|
            attachment = Decidim::Proposals::Proposal.find_by(id: id)
            attachment&.id
          end

          { "proposal_ids" => existing_ids.compact }
        end
      end
    end
  end
end
