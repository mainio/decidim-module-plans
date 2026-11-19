# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when an existing author is removed
    # from a plan.
    class RemoveAuthorFromPlan < Decidim::Command
      # Public: Initializes the command.
      #
      # plan   - The plan from which to remove the author.
      # author - The author to be removed from the plan authors.
      def initialize(plan, author)
        @plan = plan
        @author = author
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the author is removed.
      # - :invalid if the provided author was not in the plan's authors.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if author.blank?
        return broadcast(:invalid) if plan.authors.count < 2
        return broadcast(:invalid) unless author_in_plan_authors?

        remove_author

        broadcast(:ok, plan)
      end

      private

      attr_reader :plan, :author

      def author_in_plan_authors?
        coauthorship.present?
      end

      def coauthorship
        @coauthorship ||= Decidim::Coauthorship.find_by(
          coauthorable: plan,
          author:
        )
      end

      def remove_author
        coauthorship.destroy!
      end
    end
  end
end
