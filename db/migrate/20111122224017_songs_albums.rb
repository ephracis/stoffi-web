# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class SongsAlbums < ActiveRecord::Migration
  def up
    create_table :albums_songs, id: false do |t|
      t.references :song, :album
    end
  end

  def down
    drop_table :albums_songs
  end
end
