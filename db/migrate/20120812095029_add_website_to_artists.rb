# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddWebsiteToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :website, :string
  end
end
