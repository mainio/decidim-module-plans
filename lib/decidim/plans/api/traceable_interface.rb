# frozen_string_literal: true

module Decidim
  module Plans
    # This interface represents an traceable object.
    module TraceableInterface
      include GraphQL::Schema::Interface

      graphql_name "TraceableInterface"
      description "An interface that can be used in objects with traceability (versions)"

      field :versionsCount, Integer, description: "Total number of versions", method: :versions_count, null: false
      field :versions, [Decidim::Plans::TraceVersionType], description: "This object's versions", null: false
    end
  end
end
