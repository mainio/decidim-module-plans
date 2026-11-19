# frozen_string_literal: true

module Decidim
  module Plans
    module AttachedProposalsHelper
      include Decidim::ApplicationHelper
      include ActionView::Helpers::FormTagHelper

      def search_proposals
        respond_to do |format|
          format.html do
            render partial: "decidim/plans/attached_proposals/proposals"
          end
          format.json do
            scope = Decidim.find_resource_manifest(:proposals).try(:resource_scope, current_component)
            query = if scope
                      scope.joins(:proposal_state)
                           .order("decidim_proposals_proposals.title ASC")
                           .where.not(decidim_proposals_proposal_states: { token: "rejected" })
                           .where.not(published_at: nil)
                    else
                      Decidim::Proposals::Proposal.none
                    end

            # In case the search term starts with a hash character and contains
            # only numbers, the user wants to search with the ID.
            query = if params[:term] =~ /^#[0-9]+$/
                      idterm = params[:term].sub("#", "")
                      query&.where(
                        "decidim_proposals_proposals.id::text like ?",
                        "%#{idterm}%"
                      )
                    else
                      query&.where("decidim_proposals_proposals.title->>'#{current_locale}' ilike ?", "%#{params[:term]}%")
                    end

            proposals_list = query.all.collect do |p|
              ["#{present(p).title} (##{p.id})", p.id]
            end

            render json: proposals_list
          end
        end
      end
    end
  end
end
