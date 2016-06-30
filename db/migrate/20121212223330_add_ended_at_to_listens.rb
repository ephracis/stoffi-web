# -*- encoding : utf-8 -*-
# frozen_string_literal: true
class AddEndedAtToListens < ActiveRecord::Migration
  def change
    add_column :listens, :ended_at, :datetime
  end
end
