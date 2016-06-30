# frozen_string_literal: true
module SongsHelper
  def pretty_link(song)
    return link_to(song.title, song) unless song.artist
    t 'media.song.link_html',
      title: link_to(song.title, song),
      artist: link_to(song.artist.name, song.artist)
  end

  def short_link(song)
    l = link_to(song.title, song)
    l = link_to(song.artist.name, song.artist) + ' - ' + l if song.artist
    l
  end
end
