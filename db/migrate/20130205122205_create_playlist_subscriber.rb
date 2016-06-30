# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreatePlaylistSubscriber < ActiveRecord::Migration
  def up
    create_table :playlist_subscribers, id: false do |t|
      t.references :playlist, :user
    end
  end

  def down
    drop_table :playlist_subscribers
  end
end
