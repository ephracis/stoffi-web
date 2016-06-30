# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreatePlaylists < ActiveRecord::Migration
  def self.up
    create_table :playlists do |t|
      t.string :name
      t.integer :user_id
      t.boolean :is_public

      t.timestamps
    end
  end

  def self.down
    drop_table :playlists
  end
end
