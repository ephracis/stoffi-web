# frozen_string_literal: true
class RemoveSubscriptions < ActiveRecord::Migration
  def up
    Media::Playlist.all.each do |playlist|
      playlist.subscribers.each do |user|
        begin
          user.follow playlist
        rescue
        end
      end
    end
    drop_table :playlist_subscribers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
