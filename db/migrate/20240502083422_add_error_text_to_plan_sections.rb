# frozen_string_literal: true

class AddErrorTextToPlanSections < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_plans_sections, :error_text, :jsonb
  end
end
