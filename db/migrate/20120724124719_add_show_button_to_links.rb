# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddShowButtonToLinks < ActiveRecord::Migration
  def change
    add_column :links, :show_button, :boolean, default: true
  end
end
