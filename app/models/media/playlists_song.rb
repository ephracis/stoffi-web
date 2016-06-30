# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # A playlist track, ie. a song and its position in the playlist.
  class PlaylistsSong < ActiveRecord::Base
    belongs_to :playlist
    belongs_to :song
    validates :song_id, presence: true
    validates :playlist_id, presence: true
  end
end
