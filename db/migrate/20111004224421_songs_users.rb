# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class SongsUsers < ActiveRecord::Migration
  def self.up
    create_table :songs_users, id: false do |t|
      t.references :user, :song
    end
  end

  def self.down
    drop_table :songs_users
  end
end
