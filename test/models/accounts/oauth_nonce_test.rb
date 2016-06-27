require 'test_helper'

class OauthNonceTest < ActiveSupport::TestCase
  test "should create new" do
    assert_difference "Accounts::OauthNonce.count", +1 do
      assert Accounts::OauthNonce.remember(randstr, Time.now)
    end
  end
  test "should remember old" do
    nonce = Accounts::OauthNonce.remember(randstr, Time.now)
    assert_no_difference "Accounts::OauthNonce.count" do
      assert_not Accounts::OauthNonce.remember(nonce.nonce, Time.now)
    end
  end
end