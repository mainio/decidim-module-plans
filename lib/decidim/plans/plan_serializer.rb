# frozen_string_literal: true

module Decidim
  module Plans
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class PlanSerializer < Decidim::Exporters::Serializer
      include Decidim::ApplicationHelper
      include Decidim::ResourceHelper

      # Public: Initializes the serializer with a plan.
      def initialize(plan)
        @plan = plan
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        values = {
          id: plan.id,
          category: {
            id: plan.category.try(:id),
            name: plan.category.try(:name)
          },
          scope: {
            id: plan.scope.try(:id),
            name: plan.scope.try(:name)
          },
          participatory_space: {
            id: plan.participatory_space.id,
            url: Decidim::ResourceLocatorPresenter.new(plan.participatory_space).url
          },
          component: { id: component.id },
          state: plan.state.to_s,
          comments: plan.comments.count,
          attachments: plan.attachments.count,
          followers: plan.followers.count,
          published_at: plan.published_at,
          closed_at: plan.closed_at,
          url: url,
          related_proposals: {
            ids: related_proposal_ids,
            urls: related_proposal_urls
          },
          title: plan.title
        }

        # Add section content
        plan.sections.each do |sect|
          content = plan.contents.find_by(section: sect)
          values["section_#{sect.id}".to_sym] = {
            title: sect.body,
            value: content.try(:body)
          }
        end

        values
      end

      private

      attr_reader :plan

      def component
        plan.component
      end

      def related_proposal_ids
        plan.proposals.map(&:id)
      end

      def related_proposal_urls
        plan.proposals.map do |proposal|
          Decidim::ResourceLocatorPresenter.new(proposal).url
        end
      end

      def url
        Decidim::ResourceLocatorPresenter.new(plan).url
      end
    end
  end
end
