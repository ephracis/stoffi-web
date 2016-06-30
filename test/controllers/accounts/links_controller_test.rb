# frozen_string_literal: true
require 'test_helper'

module Accounts
  class LinksControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
      @link = accounts_links(:alice_facebook)
      @user = @link.user
    end

    test 'should get index' do
      sign_in @user
      get :index
      assert_redirected_to '/settings/accounts'
    end

    test 'should redirect for index when logged out' do
      get :index
      assert_redirected_to new_user_session_path
    end

    test 'should not get new' do
      assert_raises ActionController::UrlGenerationError do
        get :new
      end
    end

    test 'should not get edit' do
      assert_raises ActionController::UrlGenerationError do
        get :edit, id: @link.id
      end
    end

    test 'should create new link for signed in user' do
      @request.env['omniauth.auth'] =
        {
          'provider' => randstr(special: false),
          'uid' => randstr(special: false),
          'info' => { 'email' => @user.email },
          'credentials' => {
            'expires_at' => 2.days.from_now.to_s,
            'token' => randstr(special: false),
            'secret' => randstr(special: false)
          }
        }
      sign_in @user
      assert_difference('Accounts::Link.count') do
        post :create
      end

      assert_redirected_to '/settings/accounts'
    end

    test 'should refresh link for signed in user' do
      new_token = randstr(special: false)
      @request.env['omniauth.auth'] =
        {
          'provider' => @link.provider,
          'uid' => @link.uid,
          'credentials' => {
            'expires_at' => 2.days.from_now.to_s,
            'token' => new_token,
            'secret' => randstr(special: false)
          }
        }

      # refresh link should re-share playlist
      # playlist = @link.backlogs[0].resource.resource
      facebook_response = Object.new
      def facebook_response.parsed
        { 'status' => 'ok' }
      end
      OAuth2::AccessToken.any_instance.expects(:post)
                         .at_least_once.returns(facebook_response)
      sign_in @user
      stub_for_settings
      assert_no_difference('Accounts::Link.count') do
        post :create
      end

      assert_equal new_token, Accounts::Link.find(@link.id).access_token,
                   "Didn't update token"
    end

    test 'should create new for existing user' do
      @request.env['omniauth.auth'] =
        {
          'provider' => randstr(special: false),
          'uid' => randstr(special: false),
          'info' => { 'email' => @user.email },
          'credentials' => {
            'expires_at' => 2.days.from_now.to_s,
            'token' => randstr(special: false),
            'secret' => randstr(special: false)
          }
        }
      stub_for_settings
      assert_difference('Accounts::Link.count') do
        post :create
      end

      assert_equal @user.id, warden.session_serializer.fetch(:user).id,
                   "Didn't sign in"
    end

    test 'should create new link and new user' do
      @request.env['omniauth.auth'] =
        {
          'provider' => randstr(special: false),
          'uid' => randstr(special: false),
          'info' => { 'email' => 'new_email@mail.com' },
          'credentials' => {
            'expires_at' => 2.days.from_now.to_s,
            'token' => randstr(special: false),
            'secret' => randstr(special: false)
          }
        }
      assert_difference('Accounts::Link.count') do
        assert_difference('User.count') do
          post :create
        end
      end

      assert_equal 'new_email@mail.com', User.last.email
      assert_equal User.last.id, warden.session_serializer.fetch(:user).id,
                   "Didn't sign in"
    end

    test 'should forbid creating link via api' do
      post :create, format: :json
      assert_response :forbidden
    end

    test 'should show link' do
      sign_in @user
      get :show, id: @link.id
      assert_redirected_to '/settings/accounts'
    end

    test 'should update link' do
      sign_in @user
      enable_shares = @link.enable_shares
      stub_for_settings
      patch :update, id: @link.id, link: { enable_shares: !enable_shares }
      assert_redirected_to '/settings/accounts'
      assert_equal !enable_shares, Accounts::Link.find(@link.id).enable_shares,
                   "Setting wasn't changed"
    end

    test 'should destroy link' do
      stub_for_settings

      # this will scrape facebook for playlists
      facebook_response = Object.new
      def facebook_response.parsed
        { 'data' => [] }
      end
      OAuth2::AccessToken.any_instance.expects(:get).times(0..99)
                         .with('/me/music.playlists?limit=25&offset=0')
                         .returns(facebook_response)

      sign_in @user
      assert_difference('Accounts::Link.count', -1) do
        delete :destroy, id: @link
      end

      assert_redirected_to '/settings/accounts'
    end
  end
end
