# frozen_string_literal: true
namespace :node do
  desc 'Install latest version of node.js'
  task :install do
    on roles(:app) do
      execute :sudo, 'apt-get -y install nodejs-legacy nodejs npm'
    end
  end
  before 'juggernaut:install', 'node:install'
end
