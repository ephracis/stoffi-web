namespace :juggernaut do
	
	desc "Install version XXX of juggernaut"
	task :install do
		on roles(:app) do
			execute :sudo, "npm install -g juggernaut"
		end
	end
	after 'deploy:install', 'juggernaut:install'
	
	desc "Setup juggernaut configuration for this application"
	task :setup do
		on roles(:app) do
			# TODO
		end
	end
	after 'deploy:setup', 'juggernaut:setup'
	
	desc "Start the juggernaut server"
	task :start do
		on roles(:app) do
			background "juggernaut"
		end
	end
	after 'juggernaut:setup', 'juggernaut:start'
	
end