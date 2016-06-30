# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class RenameUrlInSongs < ActiveRecord::Migration
  def up
    rename_column :songs, :url, :foreign_url
  end

  def down
    rename_column :songs, :foreign_url, :url
  end
end
