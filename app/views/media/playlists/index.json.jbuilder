json.array!(@playlists) do |playlist|
  json.extract! playlist, :id, :slug, :name
  json.listens playlist.listens.count
  json.owner do |json|
    json.(playlist.user, :id, :name)
    json.url user_url(playlist.user)
  end
  json.songs playlist.songs do |song|
    json.(song , :id, :title)
    json.artists song.artists do |artist|
      json.(artist , :id, :name)
    end
  end
  json.url playlist_url(playlist, format: :json)
end
