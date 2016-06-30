# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddEmailToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :email, :string
  end
end
