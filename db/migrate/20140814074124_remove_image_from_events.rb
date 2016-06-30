# frozen_string_literal: true
class RemoveImageFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :image
  end
end
