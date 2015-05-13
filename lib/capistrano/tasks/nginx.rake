namespace :nginx do
	
	desc "Install the latest release of nginx"
	task :install do
		on roles(:web) do
			execute :sudo, "apt-add-repository -y ppa:nginx/stable"
			execute :sudo, "apt-get -y update"
			execute :sudo, "apt-get -y install nginx"
		end
	end
	after 'deploy:install', 'nginx:install'
	
	desc "Setup nginx configuration for this application"
	task :setup do
		on roles(:web) do
			template 'nginx.erb', '/tmp/nginx.conf'
			execute :sudo, "mv /tmp/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
			execute :sudo, "rm /etc/nginx/sites-enabled/default"
		end
	end
	after 'deploy:setup', 'nginx:setup'
	
	%w[start stop restart].each do |cmd|
		desc "#{cmd.capitalize} nginx"
		task cmd do
			on roles(:web) do
				execute :sudo, "service nginx #{cmd}"
			end
		end
	end
	after 'deploy:finished', 'nginx:restart'
	
end