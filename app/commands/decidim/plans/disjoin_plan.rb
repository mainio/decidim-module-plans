# frozen_string_literal: true

module Decidim
  module Plans
    # A command with all the business logic when author leaves/disjoins a plan.
    class DisjoinPlan < Decidim::Command
      # Public: Initializes the command.
      #
      # plan   - The plan from which to disjoin the author.
      # author - The author to be disjoint from the plan.
      def initialize(plan, author)
        @plan = plan
        @author = author
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the author is disjoint.
      # - :invalid if author cannot be disjoint from the plan.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless plan.authors.any?
        return broadcast(:invalid) unless coauthorship
        return broadcast(:invalid) if plan.created_by?(author)

        coauthorship.destroy!

        broadcast(:ok, plan)
      end

      private

      attr_reader :plan, :author

      def coauthorship
        @coauthorship ||= plan.coauthorships.find_by(author: author)
      end
    end
  end
end
