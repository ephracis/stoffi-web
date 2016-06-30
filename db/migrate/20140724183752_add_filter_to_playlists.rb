# frozen_string_literal: true
class AddFilterToPlaylists < ActiveRecord::Migration
  def change
    add_column :playlists, :filter, :string
  end
end
