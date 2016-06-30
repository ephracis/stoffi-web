# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :name
      t.integer :user_id
      t.string :last_ip
      t.string :version

      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
