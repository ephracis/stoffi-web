# frozen_string_literal: true
class DropSiteConfigs < ActiveRecord::Migration
  def change
    drop_table :admin_configs
  end
end
