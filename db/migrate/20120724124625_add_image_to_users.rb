# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddImageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image, :string
  end
end
