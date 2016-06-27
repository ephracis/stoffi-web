json.extract! @album, :id, :title, :created_at, :updated_at
json.listens @album.listens.count
json.artists @album.artists do |artist|
  json.(artist, :id, :name, :slug)
  json.url artist_url(artist, format: :json)
end
json.songs @album.songs do |song|
  json.(song , :id, :title)
  json.artists song.artists do |artist|
    json.(artist , :id, :name)
  end
end
json.url album_url(@album, format: :json)