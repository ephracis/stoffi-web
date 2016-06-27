json.array!(@albums) do |album|
  json.extract! album, :id, :title
  json.listens album.listens.count
  json.artists album.artists do |artist|
    json.(artist , :id, :name)
  end
  json.songs album.songs do |song|
    json.(song , :id, :title)
    json.artists song.artists do |artist|
      json.(artist , :id, :name)
    end
  end
  json.images album.images do |image|
    json.(image, :width, :height)
    json.url image.url
  end
  json.url album_url(album, format: :json)
end
