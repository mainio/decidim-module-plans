# frozen_string_literal: true

class AddVisibilityFieldsToPlanSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :visible_form, :boolean, null: false, default: true
    add_column :decidim_plans_sections, :visible_view, :boolean, null: false, default: true
    add_column :decidim_plans_sections, :visible_api, :boolean, null: false, default: true
  end
end
