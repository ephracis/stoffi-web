# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class CreateTranslationParameters < ActiveRecord::Migration
  def change
    create_table :admin_translation_parameters do |t|
      t.string :name
      t.string :description
      t.string :example
      t.timestamps
    end
  end
end
