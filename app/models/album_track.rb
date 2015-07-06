# This code is part of the Stoffi Music Player Project.
# Visit our website at: stoffiplayer.com
#
# Author::		Christoffer Brodd-Reijer (christoffer@stoffiplayer.com)
# Copyright::	Copyright (c) 2015 Simplare
# License::		GNU General Public License (stoffiplayer.com/license)

# Describes an album track, ie. a song and its position in the album.
class AlbumTrack < ActiveRecord::Base
	validates_presence_of :album, :song
	belongs_to :album
	belongs_to :song
end
