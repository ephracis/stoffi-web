# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddReturnToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :return_policy, :integer, default: 0
  end
end
