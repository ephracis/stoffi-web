json.array!(@events) do |event|
  json.extract! event, :id, :name, :venue, :latitude, :longitude, :start, :stop,
    :content, :category
  json.artists event.artists do |artist|
    json.(artist , :id, :name)
  end
  json.images event.images do |image|
    json.(image, :width, :height)
    json.url image.url
  end
  json.url event_url(event, format: :json)
end
