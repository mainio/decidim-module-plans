# frozen_string_literal: true

# This is not available before the latest development version but is needed.
module Decidim
  module Plans
    # This interface represents a coauthorable object.
    module CoauthorableInterface
      include GraphQL::Schema::Interface

      graphql_name "CoauthorableInterface"
      description "An interface that can be used in coauthorable objects."

      field :authorsCount, Integer, null: true, method: :coauthorships_count do
        description "The total amount of co-authors that contributed to the proposal. Note that this field may include also non-user authors like meetings or the organization"
      end

      field :author, Decidim::Core::AuthorInterface, null: true do
        description "The resource author. Note that this can be null on official proposals or meeting-proposals"
      end

      field :authors, [Decidim::Core::AuthorInterface], null: false, method: :user_identities do
        description "The resource co-authors. Include only users or groups of users"
      end

      def author
        author = object.creator_identity
        author if author.is_a?(Decidim::User) || author.is_a?(Decidim::UserGroup)
      end
    end
  end
end
