# frozen_string_literal: true
i = @start_ranking
json.array! @rank_users do |user|
  json.user do
    json.call(user, :id, :name)
    json.rank i
    json.listens user.listens.count
  end
  i += 1
end
