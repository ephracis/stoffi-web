# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddCustomNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_name, :string
  end
end
