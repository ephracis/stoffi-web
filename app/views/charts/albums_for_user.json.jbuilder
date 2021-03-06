# frozen_string_literal: true
json.array! @albums do |album|
  json.array! [
    album.title,
    album.listens.where(user: current_user).count
  ]
end
