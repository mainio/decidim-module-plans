# frozen_string_literal: true

module Decidim
  module Plans
    # This class holds the association between a Plan and a
    # Decidim::Proposals::Proposal.
    class AttachedProposal < ApplicationRecord
      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: "decidim_plan_id"
      belongs_to :proposal, class_name: "Decidim::Proposals::Proposal", foreign_key: "decidim_proposal_id"

      validates :proposal, uniqueness: { message: "may not be attached to multiple plans" }
    end
  end
end
