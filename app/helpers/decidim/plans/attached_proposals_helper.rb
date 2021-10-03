# frozen_string_literal: true

module Decidim
  module Plans
    module AttachedProposalsHelper
      include Decidim::ApplicationHelper
      include ActionView::Helpers::FormTagHelper

      def attached_proposals_picker_field(form, field)
        picker_options = {
          id: sanitize_to_id(field),
          class: "picker-multiple",
          name: "#{form.object_name}[#{field.to_s.sub(/s$/, "_ids")}]",
          multiple: true,
          autosort: true
        }
        url = search_plans_plans_path(current_component, format: :html)

        prompt_params = {
          url: url,
          text: t("proposals_picker.choose_proposals", scope: "decidim.proposals")
        }

        form.data_picker(field, picker_options, prompt_params) do |item|
          { url: url, text: item.title }
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
                        "decidim_proposals_proposals.id::text like ?",
                        "%#{idterm}%"
                      )
                    else
                      query&.where("title->>'#{current_locale}' ilike ?", "%#{params[:term]}%")
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
