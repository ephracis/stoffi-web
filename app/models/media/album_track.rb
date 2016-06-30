# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # An album track, ie. a song and its position in the album.
  class AlbumTrack < ActiveRecord::Base
    belongs_to :album
    belongs_to :song
    validates :album, :song, presence: true
  end
end
