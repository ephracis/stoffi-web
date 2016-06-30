# frozen_string_literal: true
class AddArchetypeToGenres < ActiveRecord::Migration
  def change
    add_reference :genres, :archetype, polymorphic: true, index: true
  end
end
