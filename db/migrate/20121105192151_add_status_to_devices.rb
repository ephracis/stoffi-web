# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddStatusToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :status, :string, default: 'offline'
    add_column :devices, :channels, :string, default: ''
  end
end
