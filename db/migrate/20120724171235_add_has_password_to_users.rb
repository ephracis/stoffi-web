# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddHasPasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_password, :boolean, default: true
  end
end
