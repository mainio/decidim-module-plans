# frozen_string_literal: true

class AddInformationToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :information_label, :jsonb
    add_column :decidim_plans_sections, :information, :jsonb
  end
end
