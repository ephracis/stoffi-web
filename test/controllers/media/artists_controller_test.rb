# frozen_string_literal: true
require 'test_helper'

module Media
  class ArtistsControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
      @artist = media_artists(:bob_marley)
      @admin = users(:alice)
      @user = users(:bob)
    end

    test 'should get index when logged out' do
      get :index
      assert_response :success
      assert_not_nil assigns(:artists)
    end

    test 'should get index when logged in' do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:artists)
    end

    test 'should not get new' do
      assert_raises AbstractController::ActionNotFound do
        get :new
      end
    end

    test 'should not create' do
      assert_raises AbstractController::ActionNotFound do
        assert_no_difference('Media::Artist.count') do
          post :create, artist: { name: 'Foo' }
        end
      end
    end

    test 'should show artist' do
      get :show, id: @artist
      assert_response :success
    end

    test 'should not get edit logged out' do
      get :edit, id: @artist.to_param
      assert_redirected_to new_user_session_path
    end

    test 'should not get edit as user' do
      sign_in @user
      get :edit, id: @artist.to_param
      assert_redirected_to dashboard_path
    end

    test 'should get edit as admin' do
      sign_in @admin
      get :edit, id: @artist.to_param
      assert_response :success
    end

    test 'should redirect for update artist when logged out' do
      patch :update, id: @artist, artist: { name: @artist.name }
      assert_redirected_to new_user_session_path
    end

    test 'should redirect for update artist when not admin' do
      sign_in @user
      patch :update, id: @artist, artist: { name: @artist.name }
      assert_redirected_to dashboard_path
    end

    test 'should update artist' do
      sign_in @admin
      new_name = randstr
      patch :update, id: @artist, artist: { name: new_name }
      assert_redirected_to artist_path(assigns(:artist))
      assert_equal new_name, Media::Artist.find(@artist.id).name,
                   "Didn't change name"
    end

    test 'should redirect for destroy artist when logged out' do
      assert_no_difference('Media::Artist.count') do
        delete :destroy, id: @artist
      end

      assert_redirected_to new_user_session_path
    end

    test 'should redirect for destroy artist when not admin' do
      sign_in @user
      assert_no_difference('Media::Artist.count') do
        delete :destroy, id: @artist
      end

      assert_redirected_to dashboard_path
    end

    test 'should destroy artist' do
      sign_in @admin
      assert_difference('Media::Artist.count', -1) do
        delete :destroy, id: @artist
      end

      assert_redirected_to artists_path
    end
  end
end
