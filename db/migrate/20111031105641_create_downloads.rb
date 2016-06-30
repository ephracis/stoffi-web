# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.string :ip
      t.string :channel
      t.string :arch
      t.string :file
      t.timestamps
    end
  end

  def self.down
    drop_table :downloads
  end
end
