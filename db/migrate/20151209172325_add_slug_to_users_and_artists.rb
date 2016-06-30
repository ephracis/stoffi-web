# frozen_string_literal: true
class AddSlugToUsersAndArtists < ActiveRecord::Migration
  def change
    add_column :users, :slug, :string
    add_column :artists, :slug, :string
    add_index :users, :slug, unique: true
    add_index :artists, :slug, unique: true
  end
end
