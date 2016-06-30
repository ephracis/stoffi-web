# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :artists
  end
end
