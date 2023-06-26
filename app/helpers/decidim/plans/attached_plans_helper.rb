# frozen_string_literal: true

module Decidim
  module Plans
    module AttachedPlansHelper
      def search_plans
        respond_to do |format|
          format.html do
            render partial: "decidim/plans/attached_plans/plans", layout: false
          end
          format.json do
            query = Decidim
                    .find_resource_manifest(:plans)
                    .try(:resource_scope, current_component)
                    &.published
                    &.order("title->>#{current_locale}")
                    &.where("state IS NULL OR state NOT IN ?", %w(rejected withdrawn))
                    &.where&.not(published_at: nil)

            # In case the search term starts with a hash character and contains
            # only numbers, the user wants to search with the ID.
            query = if params[:term] =~ /^#[0-9]+$/
                      idterm = params[:term].sub(/#/, "")
                      query&.where(
                        "decidim_plans_plans.id::text like ?",
                        "%#{idterm}%"
                      )
                    else
                      query&.where(
                        "title->>#{current_locale} ilike ?",
                        "%#{params[:term]}%",
                        "%#{params[:term]}%"
                      )
                    end

            plans_list = query.all.collect do |p|
              ["#{present(p).title} (##{p.id})", p.id]
            end

            render json: plans_list
          end
        end
      end
    end
  end
end
