# frozen_string_literal: true
json.array! @users do |user|
  json.array! [
    user.name,
    user.listens.count
  ]
end
