# frozen_string_literal: true

module Decidim
  module Plans
    # A service to encapsualte all the logic when searching and filtering
    # plans in a participatory process.
    class PlanSearch < ResourceSearch
      # Public: Initializes the service.
      # component   - A Decidim::Component to get the plans from.
      # page        - The page number to paginate the results.
      # per_page    - The number of plans to return per page.
      def initialize(options = {})
        super(Plan.all, options)
      end

      # Handle the search_text filter
      def search_search_text
        query.where(localized_search_text_in(:title), text: "%#{search_text}%")
      end

      # Handle the origin filter
      # The 'official' plans doesn't have an author id
      def search_origin
        if origin == "official"
          query.where.not(coauthorships_count: 0).joins(:coauthorships).where(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
        elsif origin == "citizens"
          query.where.not(coauthorships_count: 0).joins(:coauthorships).where.not(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
        else # Assume 'all'
          query
        end
      end

      # Handle the activity filter
      def search_activity
        query
      end

      # Handle the state filter
      def search_state
        case state
        when "accepted"
          query.accepted
        when "rejected"
          query.rejected
        when "evaluating"
          query.evaluating
        when "withdrawn"
          query.withdrawn
        when "except_rejected"
          query.except_rejected.except_withdrawn
        else # Assume 'not_withdrawn'
          query.except_withdrawn
        end
      end

      # Filters Plans by the name of the classes they are linked to. By default,
      # returns all Plans. When a `related_to` param is given, then it camelcases item
      # to find the real class name and checks the links for the Plans.
      #
      # The `related_to` param is expected to be in this form:
      #
      #   "decidim/meetings/meeting"
      #
      # This can be achieved by performing `klass.name.underscore`.
      #
      # Returns only those plans that are linked to the given class name.
      def search_related_to
        from = query
               .joins(:resource_links_from)
               .where(decidim_resource_links: { to_type: related_to.camelcase })

        to = query
             .joins(:resource_links_to)
             .where(decidim_resource_links: { from_type: related_to.camelcase })

        query.where(id: from).or(query.where(id: to))
      end

      def search_tag_id
        return query unless tag_id.is_a? Array

        # Fetch the plan IDs as a separate query in order to avoid duplicate
        # entries in the final result. We could also use `.distinct` on the
        # main query but that would limit what the user could further on do with
        # that query. Therefore, in this context it is safer to just fetch these
        # in a completely separate query.
        plan_ids = Plan.joins(:tags).where(
          decidim_plans_tags: { id: tag_id }
        ).distinct.pluck(:id)

        query.where(id: plan_ids)
      end

      private

      # Internal: builds the needed query to search for a text in the organization's
      # available locales. Note that it is intended to be used as follows:
      #
      # Example:
      #   Resource.where(localized_search_text_for(:title, text: "my_query"))
      #
      # The Hash with the `:text` key is required or it won't work.
      def localized_search_text_in(field)
        options[:organization].available_locales.map do |l|
          "#{field} ->> '#{l}' ILIKE :text"
        end.join(" OR ")
      end
    end
  end
end
