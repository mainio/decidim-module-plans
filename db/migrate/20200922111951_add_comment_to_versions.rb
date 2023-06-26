# frozen_string_literal: true

class AddCommentToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :comment, :jsonb
  end
end
