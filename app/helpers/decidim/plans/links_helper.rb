# frozen_string_literal: true

module Decidim
  module Plans
    module LinksHelper
      # This is for generating the links so that they maintain the search status
      def request_params(extra_params={}, exclude_params=[])
        @request_params ||= request.params.except(
          *(exclude_params + [
            :action,
            :component_id,
            :controller,
            :assembly_slug,
            :participatory_process_slug,
            :id
          ])
        ).merge(prepare_extra_params(extra_params))
      end

      def request_params_query(extra_params={}, exclude_params=[])
        return "" unless request_params(extra_params, exclude_params).any?

        "?#{request_params.to_query}"
      end

      private

      # Adds the random seed to the extra parameters to maintain the ordering
      # correctly across the requests.
      def prepare_extra_params(extra_params)
        return extra_params unless controller
        return extra_params unless controller.respond_to?(:order, true)
        return extra_params unless controller.respond_to?(:random_seed, true)

        order = controller.send(:order)
        return extra_params unless order == "random"

        seed = controller.send(:random_seed)
        return extra_params unless seed

        extra_params.merge(random_seed: seed)
      end
    end
  end
end
