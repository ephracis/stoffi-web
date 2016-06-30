# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddScoreToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :score, :integer
  end
end
