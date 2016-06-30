# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class RemoveMoreStuffFromSongs < ActiveRecord::Migration
  def up
    remove_column :songs, :track
    remove_column :songs, :year
  end

  def down
    add_column :songs, :year, :integer
    add_column :songs, :track, :integer
  end
end
