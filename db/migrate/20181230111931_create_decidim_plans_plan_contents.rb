# frozen_string_literal: true

class CreateDecidimPlansPlanContents < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_plan_contents do |t|
      t.jsonb :body, default: []
      t.references :decidim_user, index: true
      t.references :decidim_plan, index: true
      t.references :decidim_section, index: { name: "index_decidim_plans_contents_section_id" }

      t.timestamps
    end
  end
end
