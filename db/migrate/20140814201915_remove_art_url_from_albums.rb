# frozen_string_literal: true
class RemoveArtUrlFromAlbums < ActiveRecord::Migration
  def change
    remove_column :albums, :art_url
  end
end
