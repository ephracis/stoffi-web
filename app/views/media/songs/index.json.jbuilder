json.array!(@songs) do |song|
  json.extract! song, :id, :title
  json.listens song.listens.count
  json.artists song.artists do |artist|
    json.(artist , :id, :name)
  end
  json.images song.images do |image|
    json.(image, :width, :height)
    json.url image.url
  end
  json.url song_url(song, format: :json)
end
