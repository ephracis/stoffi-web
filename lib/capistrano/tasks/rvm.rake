namespace :rvm do
	task :install do
		on roles(:app) do
			execute "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
			execute "\\curl -sSL https://get.rvm.io | bash"
			execute "source ~/.rvm/scripts/rvm"
			execute "~/.rvm/bin/rvm install #{fetch(:rvm_ruby_version)}"
		end
	end
	before 'deploy:server', 'rvm:install'
end