class RenameSendToEnableInLinks < ActiveRecord::Migration
  def change
    rename_column :links, :send_shares, :enable_shares
    rename_column :links, :send_listens, :enable_listens
    rename_column :links, :send_playlists, :enable_playlists
    rename_column :links, :show_button, :enable_button
  end
end
