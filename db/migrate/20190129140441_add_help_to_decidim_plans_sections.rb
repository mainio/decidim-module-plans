# frozen_string_literal: true

class AddHelpToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :help, :jsonb
  end
end
