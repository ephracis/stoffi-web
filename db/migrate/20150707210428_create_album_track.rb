# frozen_string_literal: true
class CreateAlbumTrack < ActiveRecord::Migration
  def change
    rename_table :albums_songs, :album_tracks
    add_column :album_tracks, :id, :primary_key
    add_column :album_tracks, :position, :integer
  end
end
