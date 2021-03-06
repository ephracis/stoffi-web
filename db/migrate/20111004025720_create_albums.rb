# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.string :title
      t.integer :year
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :albums
  end
end
