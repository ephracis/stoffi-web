# frozen_string_literal: true
json.array!(@songs) do |song|
  json.extract! song, :id, :title
  json.listens song.listens.count
  json.artists song.artists do |artist|
    json.call(artist, :id, :name)
  end
  json.images song.images do |image|
    json.call(image, :width, :height)
    json.url image.url
  end
  json.url song_url(song, format: :json)
end
