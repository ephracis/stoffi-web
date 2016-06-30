# frozen_string_literal: true
class AddArchetypeToArtists < ActiveRecord::Migration
  def change
    add_reference :artists, :archetype, polymorphic: true, index: true
  end
end
