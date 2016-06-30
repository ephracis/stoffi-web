# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddAnalyzedAtToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :analyzed_at, :datetime
  end
end
