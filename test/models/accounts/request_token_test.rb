require 'test_helper'

class RequestTokenTest < ActiveSupport::TestCase
  
  setup do
    @token = Accounts::RequestToken.new
    @token.app = apps(:unused_app)
    @token.callback_url = 'http://foo.com/bar'
  end
  
  test "should authorize" do
    @token.authorize! User.first
    assert @token.verifier.present?
    assert @token.authorized?
  end
  
  test "should authorize twice" do
    @token.authorize! User.first
    verifier = @token.verifier
    assert_not @token.authorize! User.last
    assert_equal verifier, @token.verifier
    assert_equal User.first, @token.user
  end
  
  test "should exchange" do
    Accounts::RequestToken.any_instance.expects('oauth10?').returns(true).
      at_least_once
    access_token = nil
    @token.authorize! User.first
    assert_difference "Accounts::AccessToken.count", +1 do
      access_token = @token.exchange!
    end
    
    assert access_token
    assert_instance_of Accounts::AccessToken, access_token
    assert @token.invalidated?
  end
  
end