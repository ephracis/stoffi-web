class Cleanup < ActiveRecord::Migration
  def change
    remove_column :artists, :donatable_status
    remove_column :artists, :facebook
    remove_column :artists, :twitter
    remove_column :artists, :googleplus
    remove_column :artists, :myspace
    remove_column :artists, :spotify
    remove_column :artists, :youtube
    remove_column :artists, :soundcloud
    remove_column :artists, :website
    remove_column :artists, :lastfm
    remove_column :links, :do_donate
    remove_column :listens, :album_position
    remove_column :shares, :playlist_id
    remove_column :songs, :genre
    remove_column :songs, :length
    remove_column :songs, :description
    remove_column :songs, :score
    remove_column :songs, :foreign_url
    remove_column :songs, :art_url
    remove_column :songs, :analyzed_at
    remove_column :devices, :configuration_id
    
    drop_table :column_sorts
    #drop_table :columns
    drop_table :configurations
    drop_table :columns
    drop_table :donations
    drop_table :downloads
    drop_table :equalizer_profiles
    drop_table :histories
    drop_table :histories_songs
    drop_table :keyboard_shortcut_profiles
    drop_table :keyboard_shortcuts
    drop_table :list_configs
    drop_table :queues
    drop_table :queues_songs
    drop_table :song_relations
    drop_table :songs_users
    drop_table :wikipedia_links
    
  end
end
