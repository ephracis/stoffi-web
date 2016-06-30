# frozen_string_literal: true
require 'test_helper'

class OauthTokenTest < ActiveSupport::TestCase
  test 'should invalidate' do
    token = Accounts::OauthToken.new
    assert_not token.invalidated?
    token.invalidate!
    assert token.invalidated?
  end

  test 'should authorize' do
    token = Accounts::OauthToken.new
    token.authorized_at = Time.current
    assert token.authorized?
  end

  test 'should not authorize invalid token' do
    token = Accounts::OauthToken.new
    token.authorized_at = Time.current
    token.invalidated_at = Time.current
    assert_not token.authorized?
  end
end
