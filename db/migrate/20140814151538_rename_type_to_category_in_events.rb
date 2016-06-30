# frozen_string_literal: true
class RenameTypeToCategoryInEvents < ActiveRecord::Migration
  def change
    rename_column :events, :type, :category
  end
end
