# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeEdit
      class LinkProposalsCell < Decidim::Plans::SectionEditCell
        include Decidim::MapHelper

        delegate :search_proposals_plans_path, :current_component, :snippets, to: :controller

        def show
          unless snippets.any?(:plans_link_proposals)
            snippets.add(
              :plans_link_proposals,
              stylesheet_link_tag("decidim/plans/data_picker")
            )
            snippets.add(
              :plans_link_proposals,
              javascript_include_tag("decidim/plans/data_picker")
            )

            # This will display the snippets in the <head> part of the page.
            snippets.add(:head, snippets.for(:plans_link_proposals))
          end

          render
        end

        private

        def attached_proposals_picker_field(form, field)
          picker_options = {
            id: sanitize_to_id(field),
            class: "picker-multiple",
            name: "#{form.object_name}[#{field.to_s.sub(/s$/, "_ids")}]",
            multiple: true,
            autosort: true
          }
          url = search_proposals_plans_path(current_component, format: :html)

          prompt_params = {
            url: url,
            text: t("proposals_picker.choose_proposals", scope: "decidim.proposals")
          }

          form.data_picker(field, picker_options, prompt_params) do |item|
            { url: url, text: item.title }
          end
        end
      end
    end
  end
end
