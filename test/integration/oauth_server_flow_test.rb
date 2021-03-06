# frozen_string_literal: true
require 'test_helper'
require 'oauth'

class OauthServerFlowTest < ActionDispatch::IntegrationTest
  fixtures :users

  # test "get access token" do
  #
  #   # prepare user
  #   app = apps(:myapp)
  #   user = users(:bob)
  #   passwd = "foobar"
  #   set_pass(user, passwd)
  #
  #   # get request token
  #   url = "/oauth/request_token"
  #   header = oauth("post", url, {}, app, nil)
  #   post url, {}, { 'Authorization' => header }
  #   assert_response :success, "Couldn't get request token"
  #   r = Rack::Utils.parse_nested_query(@response.body)
  #   assert r['oauth_token'], "Didn't receive a request token"
  #   assert r['oauth_token_secret'], "Didn't receive a request token secret"
  #   t = Accounts::OauthToken.find_by_token(r['oauth_token'])
  #
  #   # login
  #   url = "/oauth/authorize?oauth_token=#{r['oauth_token']}"
  #   get_via_redirect url, {}, {'HTTP_REFERER' => url }
  #   post_via_redirect new_user_session_path,
  #                     user: { email: user.email, password: passwd }
  #
  #   # authorize
  #   assert_select 'a span', "Allow", "No allow button"
  #   assert_select 'a span', "Cancel", "No deny button"
  #   assert assigns(:token), "No token assigned"
  #   token = Accounts::OauthToken.find_by_token(assigns(:token).token)
  #   assert token, "No token exists"
  #   assert_equal "Accounts::RequestToken", token.type
  #   post_via_redirect "/oauth/authorize",
  #                     { oauth_token: token.token, authorize: 1 }
  #
  #   # extract token verifier
  #   assert_equal dashboard_path, path, "Didn't get redirected to dashboard"
  #   uri = URI.parse(@request.original_url)
  #   r = Rack::Utils.parse_nested_query(uri.query)
  #   assert r['oauth_verifier'], "Didn't receive a verifier"
  #   assert_not_equal 0, r['oauth_verifier'].length, "Verifier was empty"
  #
  #   # get access token
  #   url = "/oauth/access_token"
  #   params = { "oauth_verifier" => r['oauth_verifier'] }
  #   header = oauth("post", url, params, app, t)
  #   post url, params, { 'Authorization' => header }
  #   assert_response :success, "Couldn't get access token"
  #   r = Rack::Utils.parse_nested_query(@response.body)
  #   assert r['oauth_token'], "Didn't receive a access token"
  #   assert r['oauth_token_secret'], "Didn't receive a access token secret"
  #   t = Accounts::OauthToken.find_by_token(r['oauth_token'])
  #   assert t, "Couldn't find AccessToken object"
  #
  #   # access a resource with access token
  #   url = "/devices.json"
  #   params = {}
  #   header = oauth("get", url, params, app, t)
  #   get url, params, { 'Authorization' => header }
  #   assert_response :success
  # end
  #
  # test "get second access token" do
  #
  #   # prepare user
  #   app = apps(:myapp)
  #   user = users(:alice)
  #   passwd = "foobar"
  #   set_pass(user, passwd)
  #
  #   # get request token
  #   url = "/oauth/request_token"
  #   header = oauth("post", url, {}, app, nil)
  #   post url, {}, { 'Authorization' => header }
  #   assert_response :success, "Couldn't get request token"
  #   r = Rack::Utils.parse_nested_query(@response.body)
  #   assert r['oauth_token'], "Didn't receive a request token"
  #   assert r['oauth_token_secret'], "Didn't receive a request token secret"
  #   t = Accounts::OauthToken.find_by_token(r['oauth_token'])
  #
  #   # login
  #   url = "/oauth/authorize?oauth_token=#{r['oauth_token']}"
  #   get_via_redirect url, {}, {'HTTP_REFERER' => url }
  #   post_via_redirect new_user_session_path,
  #                     user: { email: user.email, password: passwd }
  #
  #   # extract token verifier
  #   assert_equal dashboard_path, path, "Didn't get redirected to dashboard"
  #   uri = URI.parse(@request.original_url)
  #   r = Rack::Utils.parse_nested_query(uri.query)
  #   assert r['oauth_verifier'], "Didn't receive a verifier"
  #   assert_not_equal 0, r['oauth_verifier'].length, "Verifier was empty"
  #
  #   # get access token
  #   url = "/oauth/access_token"
  #   params = { "oauth_verifier" => r['oauth_verifier'] }
  #   header = oauth("post", url, params, app, t)
  #   post url, params, { 'Authorization' => header }
  #   assert_response :success, "Couldn't get access token"
  #   r = Rack::Utils.parse_nested_query(@response.body)
  #   assert r['oauth_token'], "Didn't receive a access token"
  #   assert r['oauth_token_secret'], "Didn't receive a access token secret"
  #   token = Accounts::OauthToken.find_by_token(r['oauth_token'])
  #   assert token, "Couldn't find AccessToken object"
  #
  #   # access a resource with access token
  #   url = "/devices.json"
  #   params = {}
  #   header = oauth("get", url, params, app, token)
  #   get url, params, { 'Authorization' => header }
  #   assert_response :success
  # end
  #
  # test "get devices" do
  #   app = apps(:myapp)
  #   token = accounts_oauth_tokens(:alice_myapp)
  #   url = "/devices.json"
  #   params = {}
  #   header = oauth("get", url, params, app, token)
  #
  #   get url, params, { 'Authorization' => header }
  #   assert_response :success
  #
  #   devices = JSON.parse(@response.body)
  #   assert_equal 1, devices.size
  #   assert_equal devices(:alice_pc).name, devices[0]['name']
  # end
  #
  # test "get devices without auth" do
  #   get "/devices.json"
  #   assert_response :unauthorized
  # end

  def set_pass(user, passwd)
    params = { password: passwd, password_confirmation: passwd }
    assert user.update_with_password(params), 'Could not change password'
    assert user.valid_password?(passwd), 'Password did not change properly'
  end

  #
  # Code for constructing OAuth requests
  #

  # construct an Authorization header
  def oauth(verb, url, params, app, token)
    p = {
      'oauth_consumer_key' => app.key,
      'oauth_token' => token ? token.token : '',
      'oauth_signature_method' => 'HMAC-SHA1',
      'oauth_timestamp' => Time.current.to_i,
      'oauth_nonce' => generate_nonce,
      'oauth_version' => '1.0'
    }
    p['oauth_signature'] = generate_signature(
      verb,
      "http://www.example.com#{url}",
      params.merge(p),
      app.secret,
      token ? token.secret : ''
    )
    erp = p.map { |k, v| "#{k}=\"#{CGI.escape(v.to_s)}\"" } * ','
    'OAuth ' + erp
  end

  def generate_nonce
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map(&:to_a).flatten
    (0...8).map { o[rand(o.length)] }.join
  end

  def generate_signature(verb, url, params, client_secret, token_secret)
    base = generate_signature_base(verb, url, params)
    Rails.logger.debug base
    secret = CGI.escape(client_secret) + '&' + CGI.escape(token_secret)
    # hardcoded HMAC-SHA1
    digest = Digest::HMAC.digest(base, secret, ::Digest::SHA1)
    Base64.encode64(digest).chomp.delete("\n")
  end

  def generate_signature_base(verb, url, params)
    str = verb.upcase
    str += '&'
    str += CGI.escape(url)
    str += '&'
    str += CGI.escape(OAuth::Helper.normalize(params))
    str
  end
end

OAuth::Rack::OAuthFilter::ClientApplication = App
OAuth::Rack::OAuthFilter::OauthNonce = Accounts::OauthNonce
OAuth::Rack::OAuthFilter::Oauth2Token = Accounts::Oauth2Token
AccessToken = Accounts::AccessToken
