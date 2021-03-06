# frozen_string_literal: true
json.array!(@artists) do |artist|
  json.extract! artist, :id, :name
  json.listens artist.listens.count
  json.images artist.images do |image|
    json.call(image, :width, :height)
    json.url image.url
  end
  json.url artist_url(artist, format: :json)
end
