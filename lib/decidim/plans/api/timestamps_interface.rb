# frozen_string_literal: true

module Decidim
  module Plans
    module Api
      # This interface represents an object with standard create_at and
      # updated_at timestamps. This is also available in the core but it is
      # defined with the old style making it unusable with the new style of
      # GraphQL definitions.
      module TimestampsInterface
        include GraphQL::Schema::Interface

        description "An interface that can be used in objects with created_at and updated_at attributes"

        field :createdAt, Decidim::Core::DateTimeType, method: :created_at, null: false do
          description "The date and time this object was created"
        end
        field :updatedAt, Decidim::Core::DateTimeType, method: :updated_at, null: false do
          description "The date and time this object was updated"
        end
      end
    end
  end
end
