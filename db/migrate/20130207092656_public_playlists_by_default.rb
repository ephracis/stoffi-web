# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class PublicPlaylistsByDefault < ActiveRecord::Migration
  def up
    change_column :playlists, :is_public, :boolean, default: 1
  end

  def down
    change_column :playlists, :is_public, :boolean, default: 0
  end
end
