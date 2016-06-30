# frozen_string_literal: true
class RemoveForeignIdIndexFromSources < ActiveRecord::Migration
  def change
    remove_index :sources, :foreign_url
  end
end
