# frozen_string_literal: true

class AddSectionTypeToDecidimPlansSections < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_plans_sections, :section_type, :string
    execute "UPDATE decidim_plans_sections SET section_type = 'field_text_multiline'"
  end

  def down
    remove_column :decidim_plans_sections, :section_type
  end
end
