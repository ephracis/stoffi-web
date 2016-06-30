# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddDeviceToListens < ActiveRecord::Migration
  def change
    add_column :listens, :device_id, :integer
  end
end
