json.array!(@devices) do |device|
  json.extract! device, :id, :name, :display
  json.url device_url(device, format: :json)
end