# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddRefreshTokenToLinks < ActiveRecord::Migration
  def change
    add_column :links, :refresh_token, :string
    add_column :links, :token_expires_at, :datetime
  end
end
