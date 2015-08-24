require 'test_helper'

class Oauth2TokenTest < ActiveSupport::TestCase
  test "should show expiration" do
    token = Accounts::Oauth2Token.new
    token.expires_at = Time.now + 42.seconds
    assert_in_delta 42, token.expires_in, 1
  end
end