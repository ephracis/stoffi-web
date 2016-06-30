# frozen_string_literal: true
class AddSlugToPlaylists < ActiveRecord::Migration
  def change
    add_column :playlists, :slug, :string
    add_index :playlists, [:slug, :user_id], unique: true
    Media::Playlist.all.each do |playlist|
      begin
        playlist.update_attribute :slug, playlist.name.parameterize
      rescue
        playlist.update_attribute :slug, playlist.id
      end
    end
  end
end
