# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddStatusToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :status, :string, default: 'pending'
  end
end
