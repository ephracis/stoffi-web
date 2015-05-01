namespace :redis do
	
	desc "Install latest version of redis"
	task :install do
		on roles(:app) do
			# execute :sudo, "mkdir /etc/redis"
			# execute :sudo, "mkdir /var/redis"
			# execute "wget http://download.redis.io/redis-stable.tar.gz"
			# execute "tar xvzf redis-stable.tar.gz"
			# within "redis-stable" do
			# 	execute "make"
			# 	execute :sudo, "make install"
			# 	execute :sudo, "cp config/redis_init_script /etc/init.d/redis"
			# end
			execute :sudo, "apt-get -y install redis-server"
		end
	end
	before 'juggernaut:install', 'redis:install'
	
	desc "Setup redis configuration for this application"
	task :setup do
		on roles(:app) do
			template 'redis.erb', '/tmp/redis.conf'
			execute :sudo, "mv /tmp/redis.conf /etc/redis/redis.conf"
			#execute :sudo, "update-rc.d redis defaults"
		end
	end
	after 'deploy:setup', 'redis:setup'
	
	%w[start stop restart].each do |cmd|
		desc "#{cmd.capitalize} the redis server"
		task cmd do
			on roles(:app) do
				execute :sudo, "service redis-server #{cmd}"
			end
		end
	end
	after 'redis:setup', 'redis:start'
	
end