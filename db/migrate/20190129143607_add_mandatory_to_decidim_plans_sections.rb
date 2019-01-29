# frozen_string_literal: true

class AddMandatoryToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :mandatory, :boolean
  end
end
