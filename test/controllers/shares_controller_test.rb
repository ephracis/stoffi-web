# frozen_string_literal: true
require 'test_helper'

class SharesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @admin = users(:alice)
    @user = users(:bob)
  end

  test 'should not get index logged out' do
    get :index
    assert_redirected_to new_user_session_path
  end

  test 'should get index logged in' do
    sign_in @user
    get :index
    assert_response :success
  end

  test 'should show logged out' do
    get :show, id: Share.first
    assert_response :success
  end

  test 'should not get new' do
    assert_raises ActionController::UrlGenerationError do
      get :new
    end
  end

  test 'should not create logged out' do
    assert_no_difference('Share.count') do
      post :create, share: {
        resource_type: 'Song',
        resource_id: Media::Song.first.id,
        message: randstr
      }
    end
    assert_redirected_to new_user_session_path
  end

  test 'should create logged in' do
    sign_in @user
    assert_difference('Share.count') do
      post :create, share: {
        resource_type: 'Media::Song',
        resource_id: Media::Song.first.id,
        message: randstr
      }
    end
    assert_redirected_to assigns(:share)
  end

  test 'should not get edit' do
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @event
    end
  end

  test 'should not update logged out' do
    new_msg = randstr
    patch :update, id: Share.first, share: { message: new_msg }
    assert_redirected_to new_user_session_path
    assert_not_equal new_msg, Share.first.message, 'Changed message'
  end

  test "should not update someone else's" do
    share = @admin.shares.first
    sign_in @user
    new_msg = randstr
    patch :update, id: share, share: { message: new_msg }
    assert_response :missing
    assert_not_equal new_msg, Share.find(share.id).message, 'Changed message'
  end

  test 'should update as owner' do
    share = @user.shares.first
    sign_in @user
    new_msg = randstr
    patch :update, id: share, share: { message: new_msg }
    assert_redirected_to Share.find(share.id)
    assert_equal new_msg, Share.find(share.id).message, "Didn't change message"
  end

  test 'should update as admin' do
    share = @user.shares.first
    sign_in @admin
    new_msg = randstr
    patch :update, id: share, share: { message: new_msg }
    assert_redirected_to Share.find(share.id)
    assert_equal new_msg, Share.find(share.id).message, "Didn't change message"
  end

  test 'should not destroy logged out' do
    assert_no_difference('Share.count') do
      delete :destroy, id: Share.first
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy someone else's" do
    sign_in @user
    assert_no_difference('Share.count') do
      delete :destroy, id: @admin.shares.first
    end
    assert_response :missing
  end

  test 'should destroy as owner' do
    sign_in @user
    assert_difference('Share.count', -1) do
      delete :destroy, id: @user.shares.first
    end
    assert_redirected_to shares_path
  end

  test 'should destroy as admin' do
    sign_in @admin
    assert_difference('Share.count', -1) do
      delete :destroy, id: @user.shares.first
    end
    assert_redirected_to shares_path
  end
end
