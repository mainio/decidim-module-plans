# frozen_string_literal: true

module Decidim
  module Plans
    # The LinkedResourceSubject class creates the linked resource information
    # for the plan objects.
    class ResourceLinkSubject < GraphQL::Schema::Union
      graphql_name "PlanResourceLinkSubject"
      description "A plan linked resource detailed values"

      possible_types(*Decidim::Plans.api_resource_link_types)

      def self.resolve_type(object, _context)
        "#{object.class}Type".constantize
      end
    end
  end
end
