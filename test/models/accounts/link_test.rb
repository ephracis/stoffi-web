# frozen_string_literal: true
require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  test 'should create link' do
    assert_difference('Accounts::Link.count', 1, "Didn't create link") do
      l = users(:bob).links.create(provider: 'facebook')
      assert_equal users(:bob).id, l.user_id
    end
  end

  test 'should not save link without provider' do
    l = Accounts::Link.new
    assert !l.save, 'Created link without provider'
  end

  test 'should show error' do
    assert_equal 'some error', accounts_links(:alice_facebook).error
    assert_nil accounts_links(:charlie_facebook).error
  end

  test 'should update credentials' do
    auth = {
      'credentials' => {
        'expires_at' => '2014-01-07 23:56',
        'token' => 'sometoken',
        'secret' => 'somesecretstring',
        'refresh_token' => 'arefreshtoken'
      }
    }

    l = accounts_links(:alice_facebook)

    # check that failed shares in the backlog are retried
    l.expects(:share)

    l.update_credentials(auth)
    assert_equal auth['credentials']['token'], l.access_token
    assert_equal auth['credentials']['secret'], l.access_token_secret
    assert_equal auth['credentials']['refresh_token'], l.refresh_token

    # verify that listens in the backlog also get a retry
    l = accounts_links(:alice_lastfm)
    l.expects(:update_listen)
    l.update_credentials(auth)
  end

  test 'should get backend' do
    assert_instance_of Backends::Facebook,
                       accounts_links(:alice_facebook).send('backend')
  end

  test 'should get facebook picture from backend' do
    response = Object.new
    def response.parsed
      { 'data' => { 'url' => 'http://foo.com/pic.jpg' } }
    end
    OAuth2::AccessToken.any_instance.expects(:get).returns(response)
    link = accounts_links(:alice_facebook)
    assert_equal 'http://foo.com/pic.jpg', link.picture
  end
end
