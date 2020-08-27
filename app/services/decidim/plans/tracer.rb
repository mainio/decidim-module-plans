# frozen_string_literal: true

module Decidim
  module Plans
    # The Tracer class allows performing PaperTrail requests where all records
    # saved during the yield will be stored against the same transaction ID.
    # This allows saving the main record and its associated records so that the
    # same changeset can be easily identified afterwards.
    class Tracer
      def trace!(author)
        return unless block_given?

        ::PaperTrail.request(whodunnit: gid(author)) do
          yield
        end
      end

      private

      # Calculates the GlobalID of the version author. If the object does not
      # respond to `to_gid`, then it returns the object itself.
      def gid(author)
        return if author.blank?
        return author.to_gid if author.respond_to?(:to_gid)

        author
      end
    end
  end
end
