# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddMessageToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :message, :string
  end
end
