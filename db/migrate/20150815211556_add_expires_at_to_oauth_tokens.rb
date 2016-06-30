# frozen_string_literal: true
class AddExpiresAtToOauthTokens < ActiveRecord::Migration
  def change
    add_column :oauth_tokens, :expires_at, :timestamp
  end
end
