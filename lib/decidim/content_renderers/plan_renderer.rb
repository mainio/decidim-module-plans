# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing plans in content
    # and replaces it with a link to their show page.
    #
    # e.g. gid://<APP_NAME>/Decidim::Plans::Plan/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class PlanRenderer < BaseRenderer
      # Matches a global id representing a Decidim::User
      GLOBAL_ID_REGEX = %r{gid://([\w-]*/Decidim::Plans::Plan/(\d+))}i

      # Replaces found Global IDs matching an existing plan with
      # a link to its show page. The Global IDs representing an
      # invalid Decidim::Plans::Plan are replaced with '???' string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(_options = nil)
        content.gsub(GLOBAL_ID_REGEX) do |plan_gid|
          plan = GlobalID::Locator.locate(plan_gid)
          Decidim::Plans::PlanPresenter.new(plan).display_mention
        rescue ActiveRecord::RecordNotFound
          plan_gid = plan_gid.split("/").last
          "##{plan_gid}"
        end
      end
    end
  end
end
