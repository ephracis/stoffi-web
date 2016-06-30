# frozen_string_literal: true
source 'http://rubygems.org'
ruby '2.3.0'

gem 'bundler', '>= 1.8.4'

gem 'rails', '~> 4.2.0'
# gem 'rails', github: 'rails/rails'

# Use SCSS for stylesheets
gem 'sass', '~> 3.2.19'
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Use pretty markup syntax
gem 'haml', '~> 4.0.5'

# Use Devise for user authentication
gem 'devise'

# Use OmniAuth for authentication with other services
# (I don't use Devise's built-in since it didn't work when I last tried)
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-lastfm'
gem 'omniauth-linkedin'
gem 'omniauth-myspace'
gem 'omniauth-soundcloud'
gem 'omniauth-twitter'
gem 'omniauth-vimeo'
gem 'omniauth-vkontakte'
gem 'omniauth-weibo-oauth2'
gem 'omniauth-windowslive'
gem 'omniauth-yahoo'
gem 'omniauth-yandex'
gem 'omniauth-youtube'
gem 'omniauth'

# Use GeoIP so to adjust locale depending on origin
gem 'geoip'

# Keep spam away
gem 'recaptcha', require: 'recaptcha/rails'

# Let third parties access our services via OAuth
gem 'oauth-plugin'

# Paginate
gem 'kaminari'

# use solr as search engine
gem 'sunspot_rails'
gem 'sunspot_solr'

# Used to serve search suggestions based on geographical location
gem 'haversine'

# manage environment variables on heroku
gem 'figaro'

# parse durations from YouTube results
gem 'ruby-duration'

# I18n support in javacsript
gem 'i18n-js', '>= 3.0.0.rc11'

# Draw pretty charts
gem 'chartkick'

# Allow charts with data grouped by day
gem 'dateslices'

# Allow events to act_as_mappable
gem 'geokit-rails'

# Fetch image header to determine its size
gem 'fastimage'

# Perform A/B testing
gem 'split', require: 'split/dashboard'

# Activity feed
gem 'public_activity'

# Friendly URLs like `/:username/:playlist`.
gem 'friendly_id'

# Breadcrumbs
gem 'breadcrumbs_on_rails'

group :development, :test do
  gem 'sqlite3'
  gem 'teaspoon-mocha'
end

group :doc do
  gem 'sdoc'
  gem 'hanna-nouveau'
end
gem 'yard' # TODO: put this in the :doc group

group :production do
  gem 'mysql2'
end

group :test do
  gem 'webmock'
  gem 'mocha'
  gem 'capybara'
  gem 'rails-perftest'
  gem 'ruby-prof'
  gem 'codeclimate-test-reporter', require: nil
end
gem 'rubocop' # TODO: put this in the :test group

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'spring'
  gem 'dogapi'
  gem 'faker'
  gem 'progress_bar'
  gem 'colorize'
end

# bower packages via rails-assets
source 'https://rails-assets.org' do
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ui'
  gem 'rails-assets-jquery-ujs'
  gem 'rails-assets-bootstrap-sass'
  gem 'rails-assets-fontawesome'
  gem 'rails-assets-qtip2'
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-ui'
  gem 'rails-assets-angular-mocks'
  gem 'rails-assets-angulartics-google-analytics'
  gem 'rails-assets-ngmap'
  gem 'rails-assets-cryptojslib'
  gem 'rails-assets-image-picker'
  gem 'rails-assets-angular-ui-sortable'
  gem 'rails-assets-bootstrap-growl'
  gem 'rails-assets-fuelux'
end
