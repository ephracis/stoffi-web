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
			
			upload! File.expand_path("config/secrets.yml"), "#{shared_path}/config/secrets.yml"
			
			template 'profile.erb', '/tmp/.bash_profile'
			execute "mv /tmp/.bash_profile ~/.bash_profile"
			execute "touch #{shared_path}/.noseed" # flag for indicating that we have to do db:seed
		end
		
		on roles(:app, :web) do
			upload! "config/templates/www.example.com.key", '/tmp/server.key'
			execute :sudo, "mv /tmp/server.key /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.key"
			upload! "config/templates/www.example.com.cert", '/tmp/server.cert'
			execute :sudo, "mv /tmp/server.cert /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.cert"
		end
	end
	
	task :server do
		on roles(:all) do
			invoke 'deploy:install'
			invoke 'deploy:setup'
		end
	end
	
	namespace :db do
		task :seed do
			on roles(:app) do
				within release_path do
					if test("[ -f #{shared_path}/.noseed ]")
						execute :rake, "db:seed RAILS_ENV=#{fetch(:rails_env)}"
						execute "rm #{shared_path}/.noseed"
					end
				end
			end
		end
	end
	
	after "deploy:migrate", "deploy:db:seed"
end