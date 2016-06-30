# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # The relationship between a follower and a followee.
  class Following < ActiveRecord::Base
    with_options polymorphic: true do |assoc|
      assoc.belongs_to :follower
      assoc.belongs_to :followee
    end

    validates :followee_id, uniqueness: { scope:
      [:follower_id, :follower_type, :followee_type] }
  end
end
