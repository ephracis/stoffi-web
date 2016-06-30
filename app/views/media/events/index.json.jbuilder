# frozen_string_literal: true
json.array!(@events) do |event|
  json.extract! event, :id, :name, :venue, :latitude, :longitude, :start, :stop,
                :content, :category
  json.artists event.artists do |artist|
    json.call(artist, :id, :name)
  end
  json.images event.images do |image|
    json.call(image, :width, :height)
    json.url image.url
  end
  json.url event_url(event, format: :json)
end
