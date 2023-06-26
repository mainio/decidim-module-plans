# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for link_proposals field type.
      class LinkProposals < Base
        cattr_accessor :plan_resources_linked

        def prepare!(plan)
          self.class.prepare_all(plan)
        end

        def finalize!(plan)
          self.class.finalize_all(plan)
        end

        def self.prepare_all(_plan)
          self.plan_resources_linked = false

          true
        end

        def self.finalize_all(plan)
          return if plan_resources_linked

          # Go through all plan sections of this type and take note about all
          # the proposals in each section.
          proposal_ids = plan.contents.with_section_type(:link_proposals).map do |sect|
            sect.body["proposal_ids"]
          end.flatten.uniq

          # Store the included proposals in the plan object.
          proposals = Decidim::Proposals::Proposal.where(id: proposal_ids)
          plan.link_resources(proposals, "included_proposals")

          # Mark already linked so that we won't link again during the following
          # sections if there are multiple sections of the same type.
          self.plan_resources_linked = true

          true
        end
      end
    end
  end
end
