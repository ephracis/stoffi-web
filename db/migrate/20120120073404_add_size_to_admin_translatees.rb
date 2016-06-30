# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddSizeToAdminTranslatees < ActiveRecord::Migration
  def change
    add_column :admin_translatees, :size, :string
  end
end
