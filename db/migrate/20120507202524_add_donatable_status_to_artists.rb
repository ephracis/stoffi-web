# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddDonatableStatusToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :donatable_status, :string, default: 'ok'
  end
end
