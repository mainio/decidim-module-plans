# frozen_string_literal: true

class CreateDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_plans_sections do |t|
      t.integer :position, index: true
      t.jsonb :body
      t.references :decidim_component, index: true, null: false

      t.timestamps
    end
  end
end
