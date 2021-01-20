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
        @component = options[:component]
        @current_user = options[:current_user]

        base = options[:state]&.member?("withdrawn") ? Plan.withdrawn : Plan.except_withdrawn
        super(base, options)
      end

      # Handle the search_text filter
      def search_search_text
        final = query
        subq = localized_search_text_in(:title)

        # Manually search from the content sections in order to make the OR
        # query with the title.
        searchable_content_sections.each do |section|
          ref = Arel.sql("plan_content_text_#{section.id}")
          final = final.joins(
            "LEFT JOIN decidim_plans_plan_contents AS #{ref} ON #{ref}.decidim_plan_id = #{Arel.sql(query.table_name)}.id"
          )
          options[:organization].available_locales.each do |l|
            subq += " OR #{ref}.body ->> '#{l}' ILIKE :text"
          end
        end

        final.where(subq, text: "%#{search_text}%")
      end

      def search_section
        final = query
        @section_controls ||= searchable_sections.each do |s|
          manifest = s.section_type_manifest
          control = manifest.content_control_class.new
          final = control.search(final, s, section[s.id.to_s])
        end
        final
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
        case activity
        when "my_plans"
          query
            .where.not(coauthorships_count: 0)
            .joins(:coauthorships)
            .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
            .where(decidim_coauthorships: { decidim_author_id: @current_user })
        when "my_favorites"
          query.user_favorites(@current_user)
        else # Assume 'all'
          query
        end
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

      # Finds the sections that can be searched from.
      def searchable_sections
        @searchable_sections ||= Decidim::Plans::Section.where(component: @component)
      end

      def searchable_content_sections
        @searchable_content_sections ||= searchable_sections.where(
          section_type: [:field_text, :field_text_multiline]
        )
      end
    end
  end
end
