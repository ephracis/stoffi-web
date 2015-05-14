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

That's it! You are now running Stoffi on your server(s). On the app server(s) you should edit `secrets.yml` and add secret API keys if you want to integrate Stoffi with third parties such as Facebook and Google.

If you are deploying to several servers you need to configure them to talk to each other and any load balancers as this is not done by the deployment tasks.

## Getting to work

When you have everything setup you can start to do some work. Follow the usual workflow when doing work.

### Tests

Remember to continuously run the automatic tests while working to ensure that you don't break stuff by accident.

	rake test
	
### Documentation

If you need to build the documentation run the following:

	rake doc