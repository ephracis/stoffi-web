# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unique_token, :string
  end
end
