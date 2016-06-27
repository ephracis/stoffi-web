i = @start_ranking
json.array! @rank_users do |user|
  json.user do
    json.(user, :id, :name)
    json.rank i
    json.listens user.listens.count
  end
  i += 1
end
