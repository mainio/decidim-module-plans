# frozen_string_literal: true

module Decidim
  module Plans
    # A tag is a record that allows providing metadata for the items to be
    # tagged, i.e. the "taggables". In this context, only plans are taggable.
    class Tag < Plans::ApplicationRecord
      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"
      has_many :plan_taggings, foreign_key: :decidim_plans_tag_id, dependent: :destroy

      validates :organization, presence: true

      def plan_taggings_count
        PlanTagging.where(tag: self).count
      end
    end
  end
end
