# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false
  end
end
