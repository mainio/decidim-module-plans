# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the text field type.
      class LinkProposalsForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_link_proposals

        attribute :proposal_ids, Array[Integer]

        validates :proposal_ids, presence: true, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          ids = model.body["proposal_ids"]
          return unless ids.is_a?(Array)

          self.proposal_ids = ids
        end

        def body
          { proposal_ids: proposal_ids }
        end

        def proposals
          Decidim::Proposals::Proposal.where(id: proposal_ids)
        end
      end
    end
  end
end
