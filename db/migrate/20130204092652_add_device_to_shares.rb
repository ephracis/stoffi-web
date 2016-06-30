# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddDeviceToShares < ActiveRecord::Migration
  def change
    add_column :shares, :device_id, :integer
  end
end
