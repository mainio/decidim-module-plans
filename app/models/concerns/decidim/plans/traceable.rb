# frozen_string_literal: true

require "active_support/concern"

require_dependency "paper_trail/frameworks/active_record"

module Decidim
  module Plans
    # A concern that adds traceabilty capability to the given model. Including
    # this allows you the keep track of changes in the model attributes and
    # changes authorship.
    #
    # Example:
    #
    #     class MyModel < ApplicationRecord
    #       include Decidim::Plans::Traceable
    #     end
    module Traceable
      extend ActiveSupport::Concern

      included do
        # This is customized with the `:ignore` option since we don't want to
        # store another version when the item is published.
        has_paper_trail ignore: [:published_at],
                        class_name: "Decidim::Plans::PaperTrail::Version"

        delegate :count, to: :versions, prefix: true

        def last_whodunnit
          versions.last.try(:whodunnit)
        end

        def last_editor
          Decidim.traceability.version_editor(versions.last)
        end
      end

      # This is needed for the action logs to work properly. They are only
      # stored against models that implement Decidim::Traceable. However, we
      # cannot directly include that module because we want to modify its
      # functionality.
      def is_a?(klass)
        return true if klass == Decidim::Traceable
        super
      end
    end
  end
end
