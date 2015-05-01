def template(from, to)
	erb = File.read(File.expand_path("config/templates/#{from}"))
	contents = ERB.new(erb).result(binding)
	upload! StringIO.new(contents), to
end

set :mysql_password, SecureRandom.urlsafe_base64(30).gsub(/[-_]/i,'')

namespace :deploy do
	task :install do
		on roles(:all) do
			execute :sudo, "apt-get update"
			execute :sudo, "apt-get -y upgrade"
			execute :sudo, "apt-get -y install git"
		end
	end
	task :setup do
		on roles(:app) do
			execute :sudo, "mkdir -p #{fetch(:deploy_to)}"
			execute :sudo, "chgrp www-data #{fetch(:deploy_to)}"
			execute :sudo, "chmod 2775 #{fetch(:deploy_to)}"
			
			execute "mkdir -p #{shared_path}/config"
			template 'database.erb', '/tmp/database.yml'
			execute :sudo, "mv /tmp/database.yml '#{shared_path}/config/database.yml'"
			
			template 'secrets.erb', '/tmp/secrets.yml'
			execute :sudo, "mv /tmp/secrets.yml '#{shared_path}/config/secrets.yml'"
			
			template 'profile.erb', '/tmp/.bash_profile'
			execute "mv /tmp/.bash_profile ~/.bash_profile"
		end
	end
	
	task :server do
		on roles(:all) do
			invoke 'deploy:install'
			invoke 'deploy:setup'
		end
	end
end