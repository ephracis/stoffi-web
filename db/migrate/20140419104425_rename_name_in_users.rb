# frozen_string_literal: true
class RenameNameInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :name, :name_source
  end
end
