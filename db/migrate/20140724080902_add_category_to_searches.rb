# frozen_string_literal: true
class AddCategoryToSearches < ActiveRecord::Migration
  def change
    add_column :searches, :categories, :string
  end
end
