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
                    &.where("title ilike ?", "%#{params[:term]}%")
            render json: query.all.collect { |p| [present(p).title, p.id] }
          end
        end
      end
    end
  end
end
