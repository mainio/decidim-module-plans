# frozen_string_literal: true

module Decidim
  module Plans
    # A plan can accept requests to coauthor and contribute
    class PlanCollaboratorRequest < Plans::ApplicationRecord
      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: :decidim_plan_id
      belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    end
  end
end
