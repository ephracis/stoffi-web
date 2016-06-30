# frozen_string_literal: true
class RenameOptionsInLinks < ActiveRecord::Migration
  def change
    rename_column :links, :do_share, :send_shares
    rename_column :links, :do_listen, :send_listens
    rename_column :links, :do_create_playlist, :send_playlists
  end
end
