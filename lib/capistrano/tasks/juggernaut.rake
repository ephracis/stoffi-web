# yeah, it's fugly but juggernaut is temporary :)
namespace :juggernaut do
	
	desc "Install a patched version of juggernaut"
	task :install do
		on roles(:app) do
			execute :sudo, "npm install -g juggernaut"
			upload! File.expand_path("vendor/juggernaut.tar.gz"), "/tmp/juggernaut.tar.gz"
			execute :sudo, "mkdir -p /usr/local/lib/node_modules/juggernaut"
			within "/usr/local/lib/node_modules/juggernaut" do
				execute :sudo, "tar xvzf /tmp/juggernaut.tar.gz"
				execute :sudo, "ln -s /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.key keys/privatekey.pem"
				execute :sudo, "ln -s /etc/ssl/#{fetch(:application)}_#{fetch(:stage)}.cert keys/certificate.pem"
			end
		end
	end
	after 'deploy:install', 'juggernaut:install'
	
	desc "Start the juggernaut server"
	task :start do
		on roles(:app) do
			execute "screen -dm juggernaut --port #{fetch(:rails_env) == :development ? 8080 : 8443} &"
		end
	end
	after 'deploy:setup', 'juggernaut:start'
	
	desc "Stop the juggernaut server"
	task :stop do
		on roles(:app) do
			execute :sudo, "killall node"
		end
	end
	
end