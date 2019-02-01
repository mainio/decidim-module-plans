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
        query.where("title ILIKE ?", "%#{search_text}%")
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
    end
  end
end
