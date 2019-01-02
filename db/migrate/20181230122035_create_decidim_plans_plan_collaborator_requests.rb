# frozen_string_literal: true

class CreateDecidimPlansPlanCollaboratorRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_plan_collaborator_requests do |t|
      t.references :decidim_plan, null: false, index: { name: "index_plan_collab_requests_on_decidim_plans_plan_id" }
      t.references :decidim_user, null: false, index: { name: "index_plan_collab_requests_on_decidim_user_id" }

      t.timestamps
    end
  end
end
