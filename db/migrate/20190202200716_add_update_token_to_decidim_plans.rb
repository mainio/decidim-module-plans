# frozen_string_literal: true

class AddUpdateTokenToDecidimPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_plans, :update_token, :string
  end
end
