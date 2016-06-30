# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddLastfmToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :lastfm, :string
  end
end
