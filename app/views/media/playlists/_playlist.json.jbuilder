# frozen_string_literal: true
json.extract! playlist, :id, :slug, :name, :created_at, :updated_at
json.listens playlist.listens.count
json.followers playlist.followers.count
json.owner do |json|
  json.call(playlist.user, :id, :name, :slug)
  json.url user_url(playlist.user, format: :json)
end
json.songs playlist.songs do |song|
  json.call(song, :id, :title)
  json.artists song.artists do |artist|
    json.call(artist, :id, :name)
  end
end
json.url playlist_url(playlist, format: :json)
