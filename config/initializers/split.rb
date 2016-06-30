# frozen_string_literal: true
Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == Rails.application.secrets.split['username'] &&
    password == Rails.application.secrets.split['password']
end
