# frozen_string_literal: true

module Decidim
  module Plans
    # The loggability class modifies the core's Traceability class by removing
    # the PaperTrail tracing from the objects. This is needed because we want to
    # handle the PaperTrail tracing manually for the plans.
    class Loggability < ::Decidim::Traceability
      def perform_action!(action, resource, author, extra_log_info = {})
        Decidim::ApplicationRecord.transaction do
          result = block_given? ? yield : nil
          loggable_resource = resource.is_a?(Class) ? result : resource
          log(action, author, loggable_resource, extra_log_info)
          return result
        end
      end
    end
  end
end
