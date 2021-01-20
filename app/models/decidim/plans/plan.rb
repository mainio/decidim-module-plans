# frozen_string_literal: true

module Decidim
  module Plans
    # A plan is similar to a proposal but allows the users to fill in multiple
    # custom fields that the admin users define for each plans component. The
    # fields are the plan sections and the contents are in plan contents.
    class Plan < Plans::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Coauthorable
      include Decidim::HasComponent
      include Decidim::ScopableResource
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::Searchable
      include Decidim::Plans::Traceable
      include Decidim::Loggable
      include Decidim::Favorites::Favoritable

      component_manifest_name "plans"

      # Redefine the attachments association so that we can take control of the
      # uploaders related to the attachments.
      has_many :attachments,
               class_name: "Decidim::Plans::Attachment",
               dependent: :destroy,
               inverse_of: :attached_to,
               as: :attached_to

      has_many :collaborator_requests,
               class_name: "Decidim::Plans::PlanCollaboratorRequest",
               foreign_key: :decidim_plan_id,
               dependent: :destroy

      has_many :requesters,
               through: :collaborator_requests,
               source: :user,
               class_name: "Decidim::User",
               foreign_key: :decidim_user_id

      has_many :contents, foreign_key: :decidim_plan_id, dependent: :destroy

      has_many :taggings,
               class_name: "Decidim::Plans::PlanTagging",
               foreign_key: :decidim_plan_id,
               dependent: :destroy
      has_many :tags, through: :taggings

      scope :open, -> { where(state: "open") }
      scope :accepted, -> { where(state: "accepted") }
      scope :rejected, -> { where(state: "rejected") }
      scope :evaluating, -> { where(state: "evaluating") }
      scope :withdrawn, -> { where(state: "withdrawn") }
      scope :except_rejected, -> { where.not(state: "rejected").or(where(state: nil)) }
      scope :except_withdrawn, -> { where.not(state: "withdrawn").or(where(state: nil)) }
      scope :drafts, -> { where(published_at: nil) }
      scope :published, -> { where.not(published_at: nil) }

      acts_as_list scope: :decidim_component_id

      searchable_fields(
        {
          scope_id: :decidim_scope_id,
          participatory_space: { component: :participatory_space },
          A: :search_title,
          datetime: :published_at
        },
        index_on_create: ->(proposal) { proposal.visible? },
        index_on_update: ->(proposal) { proposal.visible? }
      )

      def contents
        super.where(section: sections)
      end

      def sections
        Section.where(component: component).order(:position)
      end

      def self.order_randomly(seed)
        transaction do
          connection.execute("SELECT setseed(#{connection.quote(seed)})")
          order(Arel.sql("RANDOM()")).load
        end
      end

      def self.log_presenter_class_for(_log)
        Decidim::Plans::AdminLog::PlanPresenter
      end

      # Returns a collection scoped by an author.
      # Overrides this method in DataPortability to support Coauthorable.
      def self.user_collection(author)
        return unless author.is_a?(Decidim::User)

        joins(:coauthorships)
          .where("decidim_coauthorships.coauthorable_type = ?", name)
          .where("decidim_coauthorships.decidim_author_id = ? AND decidim_coauthorships.decidim_author_type = ? ", author.id, author.class.base_class.name)
      end

      def self.geocoded_data_for(component)
        locale = Arel::Nodes.build_quoted(I18n.locale.to_s).to_sql

        # left_outer_joins(:moderation).where.not(Decidim::Moderation.arel_table[:hidden_at].eq nil

        types = %w(
          field_map_point
          field_area_scope
          field_text_multiline
        )
        cls = Arel.sql("Decidim::Plans::Plan")
        raw_data = Decidim::Plans::Content.joins(:section).joins(
          "INNER JOIN decidim_plans_plans ON decidim_plans_plans.id = decidim_plans_plan_contents.decidim_plan_id"
        ).joins(
          "LEFT OUTER JOIN decidim_moderations ON decidim_moderations.decidim_reportable_type = '#{cls}' AND decidim_moderations.decidim_reportable_id = decidim_plans_plans.id"
        ).where(
          decidim_plans_sections: { decidim_component_id: component.id }
        ).where.not(
          decidim_plans_plans: { published_at: nil }
        ).where(
          decidim_moderations: { hidden_at: nil }
        ).with_section_type(types).pluck(
          :decidim_plan_id,
          "decidim_plans_plans.title",
          "decidim_plans_sections.section_type",
          :body
        )

        plans = {}
        raw_data.each do |datapoint|
          plan_id = datapoint[0]
          plan_title = datapoint[1]
          type = datapoint[2]
          body = datapoint[3]

          plan = plans[plan_id] || {}
          plan[:id] = plan_id
          plan[:title] = plan_title
          plan[:points] ||= []

          if type == "field_map_point"
            plan[:points] << body.symbolize_keys
          elsif type == "field_area_scope"
            # TODO: We should resolve the area scope coordinates, otherwise
            # it is hard to put them to the map.
            # plan[:latitude] ||= scope_point_latitude
            # plan[:longitude] ||= scope_point_latitude
          elsif type == "field_text_multiline"
            body = plan[:body] || {}
            plan[:body] = body.map do |locale, value|
              value = "#{body[locale]} #{value}".strip
              [locale, value]
            end.to_h
          end

          plans[plan_id] = plan
        end

        plans.map do |id, plan|
          next if plan[:points].empty?

          plan[:points].map do |point|
            next if point[:latitude].blank? || point[:longitude].blank?

            {
              id: id,
              title: plan[:title],
              body: plan[:body],
              address: point[:address],
              latitude: point[:latitude],
              longitude: point[:longitude]
            }
          end.compact
        end.compact.flatten
      end

      # Public: Checks if the plan is open for edits.
      #
      # Returns Boolean.
      def open?
        state == "open"
      end

      # Public: Checks if the plan has been published or not.
      #
      # Returns Boolean.
      def published?
        published_at.present?
      end

      # Public: Checks if the plan has been closed or not.
      #
      # Returns Boolean.
      def closed?
        closed_at.present?
      end

      # Public: Checks if the plan has been closed AND not yet answered. This is
      #         interpreted as the plan waiting to be evaluated.
      #
      # Returns Boolean.
      def waiting_for_evaluation?
        closed? && !answered?
      end

      # Public: Checks if the organization has given an answer for the plan.
      #
      # Returns Boolean.
      def answered?
        answered_at.present? && state.present?
      end

      # Public: Checks if the organization has accepted a plan.
      #
      # Returns Boolean.
      def accepted?
        answered? && state == "accepted"
      end

      # Public: Checks if the organization has rejected a plan.
      #
      # Returns Boolean.
      def rejected?
        answered? && state == "rejected"
      end

      # Public: Checks if the organization has marked the plan as evaluating it.
      #
      # Returns Boolean.
      def evaluating?
        answered? && state == "evaluating"
      end

      # Public: Checks if the author has withdrawn the plan.
      #
      # Returns Boolean.
      def withdrawn?
        state == "withdrawn"
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      # Checks whether the user can edit the given plan.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        !answered? && !copied_from_other_component? && authored_by?(user)
      end

      # Checks whether the user can withdraw the given plan.
      #
      # user - the user to check for withdrawability.
      def withdrawable_by?(user)
        user && !withdrawn? && creator_author == user && !copied_from_other_component?
      end

      # Public: Whether the plan is a draft or not.
      def draft?
        published_at.nil?
      end

      def commentable?
        component.settings.comments_enabled?
      end

      def accepts_new_comments?
        commentable? && !component.current_settings.comments_blocked
      end

      def comments_have_alignment?
        true
      end

      def comments_have_votes?
        true
      end

      def users_to_notify_on_comment_created
        followers
      end

      # method for sort_link by number of comments
      ransacker :commentable_comments_count do
        query = <<-SQL
        (SELECT COUNT(decidim_comments_comments.id)
         FROM decidim_comments_comments
         WHERE decidim_comments_comments.decidim_commentable_id = decidim_plans_plans.id
         AND decidim_comments_comments.decidim_commentable_type = 'Decidim::Plans::Plan'
         GROUP BY decidim_comments_comments.decidim_commentable_id
         )
        SQL
        Arel.sql(query)
      end

      def self.export_serializer
        Decidim::Plans::PlanSerializer
      end

      def self.data_portability_images(user)
        user_collection(user).map { |p| p.attachments.collect(&:file) }
      end

      # Checks whether the plan is inside the time window to be editable or not once published.
      def within_edit_time_limit?
        true
      end

      private

      def copied_from_other_component?
        linked_resources(:plans, "copied_from_component").any?
      end
    end
  end
end
