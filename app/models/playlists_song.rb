# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2015 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

# Describes a playlist track, ie. a song and its position in the playlist.
class PlaylistsSong < ActiveRecord::Base
	validates_presence_of :playlist, :song
	belongs_to :playlist
	belongs_to :song
end
