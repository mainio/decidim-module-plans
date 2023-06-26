# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class LinkProposalsCell < Decidim::Plans::SectionDisplayCell
        include Decidim::CardHelper

        def show
          return if proposals.blank?

          render
        end

        private

        def proposals
          return [] unless model.body["proposal_ids"]

          @proposals ||= model.body["proposal_ids"].map do |id|
            Decidim::Proposals::Proposal.find_by(id: id)
          end.compact
        end
      end
    end
  end
end
