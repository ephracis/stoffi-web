# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class PlaylistsSongs < ActiveRecord::Migration
  def self.up
    create_table :playlists_songs, id: false do |t|
      t.references :playlist, :song
    end
  end

  def self.down
    drop_table :playlists_songs
  end
end
