list = @songs.map do |song|
	a = t('by', name: song.artists.map(&:name).to_sentence)
	title = song.title
	title += " #{a}" unless song.artists.empty?
	[title, song.listens_count]
end
json.array! list