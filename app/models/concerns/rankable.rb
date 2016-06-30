# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Allow resources to be sorted by rank.
module Rankable
  extend ActiveSupport::Concern

  # Static class methods
  module ClassMethods
    # Rank the resources by number of listens.
    def rank
      select("#{table_name}.*, COUNT(listens.id) AS listens_count")
        .joins(:listens)
        .group("#{table_name}.id")
        .order('listens_count DESC')
    end

    # Rank by new listens only.
    #
    # Example: `Media::Song.rank.trending`
    def trending
      where('listens.created_at > ?', 30.days.ago)
    end

    # Rank by listens only from a specific user.
    #
    # Example: `Media::Song.rank.for_user current_user`
    def for_user(user)
      where('listens.user_id = ?', user.id)
    end
  end
end
