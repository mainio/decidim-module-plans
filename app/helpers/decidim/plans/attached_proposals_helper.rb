# frozen_string_literal: true

module Decidim
  module Plans
    module AttachedProposalsHelper
      include Decidim::ApplicationHelper

      def attached_proposals_picker_field(form, name)
        picker_options = {
          id: "attached_proposals",
          "class": "picker-multiple",
          name: "proposal_ids",
          multiple: true
        }

        prompt_params = {
          url: plan_search_proposals_path(current_component, format: :html),
          text: t("decidim.plans.attached_proposals_helper.attach_proposal")
        }

        form.data_picker(name, picker_options, prompt_params) do |item|
          { url: plan_search_proposals_path(current_component, format: :json),
            text: item.title }
        end
      end

      def search_proposals
        respond_to do |format|
          format.html do
            render partial: "decidim/plans/attached_proposals/proposals"
          end
          format.json do
            query = Decidim
                    .find_resource_manifest(:proposals)
                    .try(:resource_scope, current_component)
                    &.order(title: :asc)
                    &.where("state IS NULL OR state != ?", "rejected")
                    &.where&.not(published_at: nil)

            # In case the search term starts with a hash character and contains
            # only numbers, the user wants to search with the ID.
            query = if params[:term] =~ /^#[0-9]+$/
                      idterm = params[:term].sub(/#/, "")
                      query&.where(
                        "id::text like ?",
                        "%#{idterm}%"
                      )
                    else
                      query&.where("title ilike ?", "%#{params[:term]}%")
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
