# frozen_string_literal: true
class FixNamesOnUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :avatar, :string
    User.all.each do |user|
      user.name = user.deprecated_name
      user.avatar = user.picture
    end
    remove_column :users, :name_source
    remove_column :users, :custom_name
    remove_column :users, :image_source
  end
end
