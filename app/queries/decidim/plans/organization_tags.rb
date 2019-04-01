# frozen_string_literal: true

module Decidim
  module Plans
    # This query class filters all assemblies given an organization.
    class OrganizationTags < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        q = Decidim::Plans::Tag.where(
          organization: @organization
        )
        q.order(Arel.sql("name ->> '#{current_locale}' ASC"))
      end

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
