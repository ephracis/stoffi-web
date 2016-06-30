# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddConfigurationToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :configuration_id, :int
  end
end
