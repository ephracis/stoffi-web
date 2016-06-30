# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateEqualizerProfiles < ActiveRecord::Migration
  def self.up
    create_table :equalizer_profiles do |t|
      t.string :name
      t.boolean :is_protected
      t.string :levels
      t.float :echo_level
      t.integer :configuration_id

      t.timestamps
    end
  end

  def self.down
    drop_table :equalizer_profiles
  end
end
