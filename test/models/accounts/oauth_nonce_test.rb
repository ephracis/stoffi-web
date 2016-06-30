# frozen_string_literal: true
require 'test_helper'

class OauthNonceTest < ActiveSupport::TestCase
  test 'should create new' do
    assert_difference 'Accounts::OauthNonce.count', +1 do
      assert Accounts::OauthNonce.remember(randstr, Time.current)
    end
  end
  test 'should remember old' do
    nonce = Accounts::OauthNonce.remember(randstr, Time.current)
    assert_no_difference 'Accounts::OauthNonce.count' do
      assert_not Accounts::OauthNonce.remember(nonce.nonce, Time.current)
    end
  end
end
