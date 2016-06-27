json.array! @artists do |artist|
  json.array! [
	  artist.name,
	  artist.listens.where(user: current_user).count
  ]
end
