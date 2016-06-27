json.extract! @artist, :id, :name, :created_at, :updated_at

json.listens @artist.listens.count

json.songs @artist.songs do |song|
  json.(song , :id, :title)
  json.url song_url(song, format: :json)
end

json.albums @artist.albums do |album|
  json.(album , :id, :title)
  json.url album_url(album, format: :json)
end

json.url artist_url(@artist, format: :json)