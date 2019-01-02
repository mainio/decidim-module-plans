# frozen_string_literal: true

module Decidim
  module Proposals
    # A collaborative_draft can accept requests to coauthor and contribute
    class PlanCollaboratorRequest < Plans::ApplicationRecord
      validates :plan, :user, presence: true

      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: :decidim_plan_id
      belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    end
  end
end
