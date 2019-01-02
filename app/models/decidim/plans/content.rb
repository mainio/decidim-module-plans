# frozen_string_literal: true

module Decidim
  module Plans
    # The content record is the actual content for each plan section for a
    # single plan.
    class Content < Plans::ApplicationRecord
      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: "decidim_plan_id"
      belongs_to :section, class_name: "Decidim::Plans::Section", foreign_key: "decidim_plan_id"
      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id"
    end
  end
end
