json.array!(@genres) do |genre|
	json.extract! genre, :id, :name
  json.listens genre.listens.count
  json.songs genre.songs.rank.limit(10) do |song|
    json.(song , :id, :title)
    json.artists song.artists do |artist|
      json.(artist , :id, :name)
    end
  end
  json.images genre.images do |image|
    json.(image, :width, :height)
    json.url image.url
  end
	json.url genre_url(genre, format: :json)
end
