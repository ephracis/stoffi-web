# frozen_string_literal: true
class AddPositionToPlaylistsSongs < ActiveRecord::Migration
  def change
    add_column :playlists_songs, :id, :primary_key
    add_column :playlists_songs, :position, :integer
  end
end
