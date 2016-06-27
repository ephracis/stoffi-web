json.array! @genres do |genre|
  json.array! [
    genre.name,
    genre.listens.where(user: current_user).count
  ]
end
