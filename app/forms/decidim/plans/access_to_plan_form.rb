# frozen_string_literal: true

module Decidim
  module Plans
    # A form object common to accept and reject actions requesters of Plans.
    class AccessToPlanForm < Decidim::Form
      mimic :plan

      attribute :id, String
      attribute :requester_user_id, String
      attribute :state, String

      validates :id, :requester_user_id, presence: true
      validates :state, presence: true, inclusion: { in: %w(open) }

      validate :existence_of_requester_in_requesters

      def plan
        @plan ||= Decidim::Plans::Plan.find id if id
      end

      def requester_user
        @requester_user ||= Decidim::User.find_by(id: requester_user_id, organization: current_organization) if requester_user_id
      end

      private

      def existence_of_requester_in_requesters
        return unless plan

        errors.add(:requester_user_id, :invalid) unless plan.requesters.exists? requester_user_id
      end
    end
  end
end
