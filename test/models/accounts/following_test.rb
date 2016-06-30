# frozen_string_literal: true
require 'test_helper'

class FollowingTest < ActiveSupport::TestCase
  test 'should create' do
    assert_difference 'Accounts::Following.count', +1 do
      assert Accounts::Following.create(followee_id: 123)
    end
  end
end
