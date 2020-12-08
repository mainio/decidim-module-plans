# frozen_string_literal: true

module Decidim
  module Plans
    # The LinkedResourceSubject class creates the linked resource information
    # for the plan objects.
    class ResourceLinkSubject < GraphQL::Schema::Union
      graphql_name "PlanResourceLinkSubject"
      description "A plan linked resource detailed values"

      def self.resolve_type(object, _context)
        "#{object.class}Type".constantize
      end
    end
  end
end
