# frozen_string_literal: true
class AddIndexUniqueEmailInUsers < ActiveRecord::Migration
  def change
    # add_index :users, :email, :unique => true
  end
end
