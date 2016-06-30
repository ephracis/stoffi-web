# frozen_string_literal: true
class AddAccessTokenSecretToLinks < ActiveRecord::Migration
  def change
    add_column :links, :access_token_secret, :string
  end
end
