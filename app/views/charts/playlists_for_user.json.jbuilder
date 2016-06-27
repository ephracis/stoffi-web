json.array! @playlists do |playlist|
  json.array! [
    playlist.name,
    playlist.listens.where(user: current_user).count
  ]
end
