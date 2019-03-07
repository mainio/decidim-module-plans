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
        ).merge(extra_params)
      end

      def request_params_query(extra_params={}, exclude_params=[])
        return "" unless request_params(extra_params, exclude_params).any?

        "?#{request_params.to_query}"
      end
    end
  end
end
