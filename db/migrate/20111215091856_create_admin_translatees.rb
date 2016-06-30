# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateAdminTranslatees < ActiveRecord::Migration
  def change
    create_table :admin_translatees do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
