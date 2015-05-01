namespace :mysql do
	
	desc "Install the latest release of mysql"
	task :install do
		on roles(:db) do
			execute "echo 'mysql-server-5.6 mysql-server/root_password password root' | sudo debconf-set-selections"
			execute "echo 'mysql-server-5.6 mysql-server/root_password_again password root' | sudo debconf-set-selections"
			execute :sudo, "apt-get -y install mysql-server"
		end
	end
	after 'deploy:install', 'mysql:install'
	
	desc "Setup mysql configuration for this application"
	task :setup do
		on roles(:db) do
			pass = fetch(:mysql_password)
			dbname = user = "#{fetch(:application)}_#{fetch(:rails_env)}"
			
			# create db user if it doesn't exist
			execute "mysql -u root -proot mysql -e \"GRANT USAGE ON *.* TO '#{user}'@'localhost';\""
			# then drop it
			execute "mysql -u root -proot mysql -e \"DROP USER '#{user}'@'localhost';\""
			# then create it properly
			execute "mysql -u root -proot mysql -e \"CREATE USER '#{user}'@'localhost' IDENTIFIED BY '#{pass}';\""
			execute "mysql -u root -proot mysql -e \"GRANT ALL PRIVILEGES ON #{dbname}.* TO '#{user}'@'localhost';\""
		end
	end
	after 'deploy:setup', 'mysql:setup'
	
	%w[start stop restart].each do |cmd|
		desc "#{cmd.capitalize} mysql"
		task cmd do
			on roles(:db) do
				execute :sudo, "service mysql #{cmd}"
			end
		end
	end
	after 'mysql:setup', 'mysql:restart'
	
end