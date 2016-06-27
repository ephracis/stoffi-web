json.array! @songs do |song|
  artists = t('by', creator: song.artists.map(&:name).
                    to_sentence)
	title = song.title
	title += " #{artists}" unless song.artists.empty?
  json.array! [
	  song.title,
    song.listens.where(user: current_user).count
  ]
end
