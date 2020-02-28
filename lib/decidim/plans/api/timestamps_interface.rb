# frozen_string_literal: true

module Decidim
  module Plans
    # This interface represents a timestampable object.
    module TimestampsInterface
      include GraphQL::Schema::Interface

      graphql_name "TimestampsInterface"
      description "An interface that can be used in objects created_at and updated_at attributes"

      field :createdAt, Decidim::Core::DateTimeType, null: true, method: :created_at do
        description "The date and time this object was created"
      end

      field :updatedAt, Decidim::Core::DateTimeType, null: true, method: :updated_at do
        description "The date and time this object was updated"
      end
    end
  end
end
