# The Stoffi Website

As you may know, Stoffi is divided into two parts: the player (hopefully it will soon be 'players') and the website.

The website, also know as the Cloud, is the central point which ties all your devices together and acts as a central repository for all configurations, playlists and statistics. The website is also the communicator between the player and the rest of the Internet such as Facebook and Google.

## Getting started

If you are reading this you are probably interested in getting the Stoffi website setup on your own development machine. Since the website is rather complex, there are a few steps you need to complete in order to get it up and running.

Here we assume you have a freshly installed server running Ubuntu 14.04 without anything extra installed on it. To prepare your server you need to run this:

    curl -sL http://git.io/vUXTQ | bash | ssh user@hostname -T

Now your server is ready for our deployment tasks. Before you start deploying you need to decide what stage your want to deploy: beta, staging or production. Then you have to configure some stuff. You need to specify the IP of your servers, what roles they should have (web, database, app), what ports to use, and so on. Edit the file for your stage:

    vim config/deploy/STAGE.rb

When you are finished telling the deployment system what your environment looks like, it's time to start the deployment. First you need to install and configure all the software needed to run Stoffi:

    cap STAGE deploy:server

Then you can check that everything is as it should:

    cap STAGE deploy:check

If everything went fine, it's time to deploy!

    cap STAGE deploy

That's it! You are now running Stoffi on your server(s). On the app server(s) you should edit `/home/deployer/.bash_profile` and add secret API keys if you want to integrate Stoffi with third parties such as Facebook and Google.

## OLD INSTRUCTIONS:

### Prerequisites

First I suggest you setup Ruby and Ruby on Rails along with a web server on your machine. I suggest you check out Pow as a local web server. It is fast and easy to deploy. I also suggest you use RVM to manage various ruby versions. The current master branch of Stoffi is developed using Ruby 2.1.

You also need to install Juggernaut in order to get server-to-client communication up and running. I will move to WebSockets later when I have managed to switch to a more modern browser for the embedded version inside the player. But for now, we still use Juggernaut. Here's how you install it, assuming you use Homebrew as a package manager.

Install Node.js:

	brew install node
	
Install Redis:

	brew install redis
	
Install juggernaut:

	npm install -g juggernaut
	
For some reason I didn't get the latest version of Juggernaut to work. It started to run but never served any requests. I have packaged the folder from the web server which *does* work, and put it into the `vendor` folder. Unpack this into the juggernaut installation folder, which is most likely `/usr/local/lib/node_modules/juggernaut`.

### Database setup

Start by creating the database configuration file `config/database.yml`. TODO: add a default configuration file but prevent it from being changed accidentally.

Then create the database:

	rake db:create
	
You may need to migrate to the latest version of the schema. TODO: this shouldn't be needed!

	rake db:migrate
	
Now initialize the database:

	rake db:seed
	
### Start services

Start redis:

	redis-server

Start juggernaut:

	juggernaut --port 8080
	
Note that if you decide to serve the website over https you should change the port to 8443.

Start the sunspot search engine:

	rake solr:sunspot:start
	
TODO: perhaps we could combine all these into a single rake task?

### NEW: deploy with Capistrano

#### Setup server

We assume you have a newly created Ubuntu 14.04 machine. The following command will initialize the server:

    curl -sL http://git.io/vJZRe | bash | ssh user@hostname -T

Essentially is creates a user for deployment which will be used when running the deployment tasks.

#### Configuration

Open the file for the stage you want to deploy to `config/deploy/STAGE.rb` and set the parameters to your liking.

#### Deploy

Next you want to install all the necessary software, put stuff in the right folders, set things to start at boot, tweak configuration files, etc. All this is done using the following command:

    cap STAGE deploy:install

Then you want to actually push the code up to the server and start the application:

    cap STAGE deploy

### Secrets

If you want integration with other service providers such as Facebook, Gooogle, etc. you need to add some stuff to the file `config/secrets.yml`.

TODO: create default sample file with instructions.

## Getting to work

When you have everything setup you can start to do some work. Follow the usual workflow when doing work.

### Tests

Remember to continuously run the automatic tests while working to ensure that you don't break stuff by accident.

	rake test
	
### Documentation

If you need to build the documentation run the following:

	rake doc