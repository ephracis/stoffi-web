json.extract! song, :id, :title, :created_at, :updated_at

json.listens song.listens.count

json.sources song.sources do |source|
  json.(source , :id, :name, :foreign_id, :path)
end

json.artists song.artists do |artist|
  json.(artist , :id, :name)
  json.url artist_url(artist, format: :json)
end

json.genres song.genres do |genre|
  json.(genre , :id, :name)
  json.url genre_url(genre, format: :json)
end

if current_user.admin?
  json.duplicates song.duplicates do |duplicate|
    json.(duplicate , :id, :title)
    json.url song_url(duplicate, format: :json)
  end
end

json.url song_url(song, format: :json)
