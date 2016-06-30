# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddClientApplicationsToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :client_application_id, :int
  end
end
