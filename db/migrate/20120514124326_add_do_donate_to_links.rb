# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddDoDonateToLinks < ActiveRecord::Migration
  def change
    add_column :links, :do_donate, :boolean, default: true
  end
end
