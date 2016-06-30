# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddAdSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_ads, :string, default: 'all'
  end
end
