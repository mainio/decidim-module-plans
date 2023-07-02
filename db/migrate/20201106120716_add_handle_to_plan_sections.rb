# frozen_string_literal: true

class AddHandleToPlanSections < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_plans_sections, :handle, :string
    add_index :decidim_plans_sections, :handle

    reversible do |dir|
      dir.up do
        Decidim::Plans::Section.all.each do |section|
          section.update(handle: "section_#{section.id}")
        end
      end
    end
  end
end
