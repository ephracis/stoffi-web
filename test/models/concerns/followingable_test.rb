# frozen_string_literal: true
require 'test_helper'

class FollowingableTest < ActiveSupport::TestCase
  setup do
    @user1 = users(:alice)
    @user2 = users(:bob)
  end

  test 'should follow' do
    x = @user2.playlists.first
    assert_not @user1.follows?(x)
    @user1.follow(x)
    assert @user1.follows?(x)
    assert_includes @user1.follows, x
  end

  test 'should unfollow' do
    x = @user2.playlists.first
    @user1.follow(x)
    assert @user1.follows?(x)
    @user1.unfollow(x)
    assert_not @user1.follows?(x)
    assert_not_includes @user1.follows, x
  end
end
