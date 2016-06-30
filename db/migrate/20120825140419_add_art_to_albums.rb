# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddArtToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :art_url, :string
  end
end
