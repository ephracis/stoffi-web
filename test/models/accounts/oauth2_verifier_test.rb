# frozen_string_literal: true
require 'test_helper'

class Oauth2VerifierTest < ActiveSupport::TestCase
  test 'should exchange' do
    verifier = Accounts::Oauth2Verifier.new
    verifier.user = User.first
    verifier.app = App.first

    token = nil
    assert_difference 'Accounts::Oauth2Token.count', +1 do
      token = verifier.exchange!
    end

    assert token
    assert_instance_of Accounts::Oauth2Token, token
    assert_not verifier.valid?
  end
end
