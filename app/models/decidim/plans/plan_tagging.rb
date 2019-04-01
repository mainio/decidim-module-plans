# frozen_string_literal: true

module Decidim
  module Plans
    # A plan tagging is a record that maps the plans with the tags.
    class PlanTagging < Plans::ApplicationRecord
      belongs_to :plan, class_name: "Decidim::Plans::Plan", foreign_key: :decidim_plan_id
      belongs_to :tag, class_name: "Decidim::Plans::Tag", foreign_key: :decidim_plans_tag_id

      validates :plan, :tag, presence: true
    end
  end
end
