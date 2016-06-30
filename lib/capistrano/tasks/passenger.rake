# frozen_string_literal: true
namespace :passenger do
  desc 'Install the latest release of passenger'
  task :install do
    on roles(:app) do
      repo = 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main'

      # add keys
      execute :sudo, 'apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7'
      execute :sudo, 'apt-get -y install apt-transport-https ca-certificates'

      # add repo
      upload! StringIO.new(repo), '/tmp/passenger.list'
      execute 'chmod 644 /tmp/passenger.list'
      execute :sudo, 'chown root: /tmp/passenger.list'
      execute :sudo, 'mv /tmp/passenger.list /etc/apt/sources.list.d/passenger.list'

      # install
      execute :sudo, 'apt-get -y update'
      execute :sudo, 'apt-get -y install passenger'
    end
  end
  after 'deploy:install', 'passenger:install'

  desc 'Setup passenger configuration for this application'
  task :setup do
    on roles(:app) do
      template 'passenger_init.erb', '/tmp/passenger_init'
      template 'passenger_conf.erb', '/tmp/passenger_conf'
      execute :sudo, 'mkdir -p /etc/passenger.d'
      execute :sudo, 'mv /tmp/passenger_init /etc/init.d/passenger'
      execute :sudo, 'chmod +x /etc/init.d/passenger'
      execute :sudo, "mv /tmp/passenger_conf /etc/passenger.d/#{fetch(:stage)}.yml"
    end
  end
  after 'deploy:setup', 'passenger:setup'

  %w(start stop restart).each do |cmd|
    desc "#{cmd.capitalize} phusion passenger"
    task cmd do
      on roles(:app) do
        execute :sudo, "service passenger #{cmd}"
      end
    end
  end
  after 'deploy:finished', 'passenger:restart'
end
