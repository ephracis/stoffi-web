# frozen_string_literal: true
require 'test_helper'

module Accounts
  class OauthControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
    end

    test 'should redirect when logged out' do
      get :authorize
      assert_redirected_to new_user_session_path
    end

    test 'should get authorize page' do
      user = users(:bob)
      app = App.first
      sign_in user
      get :authorize, client_id: app.key
      assert_response :success
    end

    test 'should authorize first time' do
      user = users(:bob)
      app = App.first
      token = Accounts::RequestToken.create(
        token: randstr(special: false),
        app: app
      )
      sign_in user
      post :authorize, client_id: app.key, oauth_token: token.token
      assert_response :success
    end

    test 'should skip authorization second time' do
      user = users(:bob)
      app = apps(:popular_app)
      assert_includes user.get_apps(:added), app,
                      'Test assumes user has added app'
      token = Accounts::RequestToken.create(
        token: randstr(special: false),
        app: app
      )
      callback = "#{app.callback_url}&oauth_token="\
                 "#{token.token}&oauth_verifier="
      sign_in user
      get :authorize, client_id: app.key, oauth_token: token.token
      assert_response :redirect
      assert_match(/#{Regexp.escape(callback)}/, @response.redirect_url)
    end
  end
end
