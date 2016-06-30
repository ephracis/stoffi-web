# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class SongsArtists < ActiveRecord::Migration
  def up
    create_table :songs_artists, id: false do |t|
      t.references :song, :artist
    end
  end

  def down
    drop_table :songs_artists
  end
end
