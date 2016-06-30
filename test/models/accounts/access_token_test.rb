# frozen_string_literal: true
require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase
  test 'should create' do
    assert_difference 'Accounts::AccessToken.count', +1 do
      token = Accounts::AccessToken.create(user: User.first, app: App.first)
      assert_in_delta Time.current.to_i, token.authorized_at.to_i, 3,
                      'Authorized timestamp not set correctly'
    end
  end

  test 'should not create without user' do
    assert_no_difference 'Accounts::AccessToken.count',
                         'Created new token without user' do
      Accounts::AccessToken.create
    end
  end
end
