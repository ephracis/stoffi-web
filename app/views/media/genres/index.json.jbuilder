# frozen_string_literal: true
json.array!(@genres) do |genre|
  json.extract! genre, :id, :name
  json.listens genre.listens.count
  json.songs genre.songs.rank.limit(10) do |song|
    json.call(song, :id, :title)
    json.artists song.artists do |artist|
      json.call(artist, :id, :name)
    end
  end
  json.images genre.images do |image|
    json.call(image, :width, :height)
    json.url image.url
  end
  json.url genre_url(genre, format: :json)
end
