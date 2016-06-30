# frozen_string_literal: true
# yeah, it's fugly but juggernaut is temporary :)
namespace :juggernaut do
  desc 'Install a patched version of juggernaut'
  task :install do
    on roles(:app) do
      execute :sudo, 'npm install -g juggernaut'
      upload! File.expand_path('vendor/juggernaut.tar.gz'), '/tmp/juggernaut.tar.gz'
      execute :sudo, 'mkdir -p /usr/local/lib/node_modules/juggernaut'
      within '/usr/local/lib/node_modules/juggernaut' do
        execute :sudo, 'tar xvzf /tmp/juggernaut.tar.gz'
        execute :sudo, "ln -s /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.key keys/privatekey.pem"
        execute :sudo, "ln -s /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.cert keys/certificate.pem"
      end
      template 'juggernaut.erb', '/tmp/juggernaut.conf'
      execute :sudo, 'mv /tmp/juggernaut.conf /etc/init/juggernaut.conf'
    end
  end
  after 'deploy:install', 'juggernaut:install'

  %w(start stop restart).each do |cmd|
    desc "#{cmd.capitalize} juggernaut"
    task cmd do
      on roles(:web) do
        execute :sudo, "service juggernaut #{cmd}"
      end
    end
  end
  after 'deploy:setup', 'juggernaut:start'
end
