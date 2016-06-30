# frozen_string_literal: true
class AddAccessTokenToLinks < ActiveRecord::Migration
  def change
    add_column :links, :access_token, :string
  end
end
