# frozen_string_literal: true

class AddClosedAtToDecidimPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :closed_at, :datetime
    add_index :decidim_plans_plans, :closed_at
  end
end
