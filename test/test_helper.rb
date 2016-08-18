# frozen_string_literal: true

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'capybara/rails'

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in
    # alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in
    # integration tests
    # -- they do not yet inherit this setting
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def setup
      WebMock.disable_net_connect! allow_localhost: false
      path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
      @image_stub = stub_request(:get,
                                 %r{https?://.*\.jpe?g})
                    .to_return(body: File.new(path), status: 200)
      @sunspot_stub = stub_request(:post,
                                   %r{http://localhost:8981/.*})
    end

    def teardown
      WebMock.allow_net_connect!
      remove_request_stub @image_stub if @image_stub
      remove_request_stub @sunspot_stub if @sunspot_stub
    end

    # Generate a random string.
    def randstr(options = {})
      default = options.all? { |_k, v| v == false }
      options = {
        length: 20, lower: default, upper: default, special: default,
        numbers: default
      }.merge(options)
      chars = randstr_keyspace options
      Array.new(options[:length]) { chars[rand(chars.length)].chr }.join
    end

    # The keyspace for generating a random string.
    def randstr_keyspace(options)
      [
        options[:lower] ? 'abcdefghjklmnopqrstuvwxyz' : '',
        options[:upper] ? 'ABCDEFGHJKLMNOPQRSTUVWXYZ' : '',
        options[:numbers] ? '0123456789' : '',
        # special are multiplied to increase their probability
        options[:special] ? "`!@#$%^&*()_+{}|:\\\"\'~-=[];',./?<>" * 3 : ''
      ].join
    end
  end
end

module ActionController
  class TestCase
    include PlaylistHelperController
    def setup
      WebMock.disable_net_connect! allow_localhost: false
      path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
      @image_stub = stub_request(:get,
                                 %r{https?://.*\.jpe?g})
                    .to_return(body: File.new(path), status: 200)
      @sunspot_stub = stub_request(:post,
                                   %r{http://localhost:8981/.*})
    end

    def teardown
      WebMock.allow_net_connect!
      remove_request_stub @image_stub if @image_stub
      remove_request_stub @sunspot_stub if @sunspot_stub
    end

    def stub_for_settings
      stub_lastfm_oauth
      stub_twitter_oauth
      stub_facebook_oauth
    end

    def stub_lastfm_oauth
      lastfm_link = accounts_links(:alice_lastfm)
      lastfm_response = Object.new
      def lastfm_response.parsed
        { 'user' => { 'name' => 'lfm_name', 'realname' => 'Lastfm Name' } }
      end
      lastfm_url = '/2.0/?method=user.getinfo&format=json&'\
                   "user=#{lastfm_link.uid}&api_key=somerandomid"
      OAuth2::AccessToken.any_instance.expects(:get).times(0..99)
                         .with(lastfm_url).returns(lastfm_response)
    end

    def stub_twitter_oauth
      twitter_link = accounts_links(:alice_twitter)
      twitter_response = Object.new
      def twitter_response.body
        { 'screename' => 'tw_name', 'name' => 'Twitter Name' }.to_json
      end
      twitter_url = 'https://api.twitter.com/1.1/users/show.json?'\
                    "user_id=#{twitter_link.uid}"
      OAuth::AccessToken.any_instance.expects(:request).times(0..99)
                        .with(:get, twitter_url, nil).returns(twitter_response)
    end

    def stub_facebook_oauth
      facebook_response = Object.new
      def facebook_response.parsed
        { 'username' => 'fb_name', 'name' => 'Facebook Name' }
      end
      OAuth2::AccessToken.any_instance.expects(:get).times(0..99)
                         .with('/me?fields=name,username')
                         .returns(facebook_response)
      OAuth2::AccessToken.any_instance.expects(:get).times(0..99)
                         .with('/me/picture?type=large&redirect=false')
                         .returns(facebook_response)
    end
  end
end

module ActionDispatch
  class IntegrationTest
    include PlaylistHelperController
    include Capybara::DSL

    def set_pass(user, passwd)
      params = { password: passwd, password_confirmation: passwd }
      assert user.update_with_password(params), 'Could not change password'
      assert user.valid_password?(passwd), 'Password did not change properly'
    end

    def sign_in(user)
      pw = (0...20).map { ('a'..'z').to_a[rand(26)] }.join
      set_pass user, pw
      post_via_redirect new_user_session_path,
                        user: { email: user.email, password: pw }
    end
  end
end

require 'mocha/setup'
