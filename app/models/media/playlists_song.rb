# Copyright (c) 2015 Simplare

module Media
  
  # A playlist track, ie. a song and its position in the playlist.
  class PlaylistsSong < ActiveRecord::Base
    belongs_to :playlist
    belongs_to :song
    validates_presence_of :playlist, :song
  end
  
end