# frozen_string_literal: true
require 'test_helper'

module Media
  class GenresControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup do
      @genre = media_genres(:reggae)
      @admin = users(:alice)
      @user = users(:bob)
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end

    test 'should get index logged in' do
      sign_in @user
      get :index
      assert_response :success
      assert_not_nil assigns(:genres)
    end

    test 'should get index logged out' do
      get :index
      assert_response :success
      assert_not_nil assigns(:genres)
    end

    test 'should get show logged in' do
      sign_in @user
      get :show, id: @genre.to_param
      assert_response :success
    end

    test 'should get show logged out' do
      get :show, id: @genre.to_param
      assert_response :success
    end

    test 'should not show missing' do
      get :show, id: 'foobar'
      assert_response :not_found
    end

    test 'should not get new' do
      assert_raises AbstractController::ActionNotFound do
        get :new
      end
    end

    test 'should not create logged out' do
      assert_no_difference('Media::Genre.count') do
        post :create, genre: { name: 'Foo' }
      end
      assert_redirected_to new_user_session_path
    end

    test 'should create genre as user' do
      sign_in @user
      assert_difference('Media::Genre.count') do
        post :create, genre: { name: 'Foo' }
      end
      assert_redirected_to genre_path(assigns(:genre))
    end

    test 'should create genre as admin' do
      sign_in @admin
      assert_difference('Media::Genre.count') do
        post :create, genre: { name: 'Foo' }
      end
      assert_redirected_to genre_path(assigns(:genre))
    end

    test 'should not get edit logged out' do
      get :edit, id: @genre.to_param
      assert_redirected_to new_user_session_path
    end

    test 'should not get edit as user' do
      sign_in @user
      get :edit, id: @genre.to_param
      assert_redirected_to dashboard_path
    end

    test 'should get edit as admin' do
      sign_in @admin
      get :edit, id: @genre.to_param
      assert_response :success
    end

    test 'should not update genre logged out' do
      patch :update, id: @genre, genre: { name: 'New name' }
      assert_redirected_to new_user_session_path
      assert_not_equal 'New name', Media::Genre.find(@genre.id).name,
                       'Changed name'
    end

    test 'should not update genre as user' do
      sign_in @user
      patch :update, id: @genre, genre: { name: 'New name' }
      assert_redirected_to dashboard_path
      assert_not_equal 'New name', Media::Genre.find(@genre.id).name,
                       'Changed name'
    end

    test 'should update genre as admin' do
      sign_in @admin
      patch :update, id: @genre, genre: { name: 'New name' }
      assert_redirected_to genre_path(assigns(:genre))
      assert_equal 'New name', Media::Genre.find(@genre.id).name,
                   "Didn't change name"
    end

    test 'should not destroy genre logged out' do
      assert_no_difference('Media::Genre.count') do
        delete :destroy, id: @genre
      end
      assert_redirected_to new_user_session_path
    end

    test 'should not destroy genre as user' do
      sign_in @user
      assert_no_difference('Media::Genre.count') do
        delete :destroy, id: @genre
      end
      assert_redirected_to dashboard_path
    end

    test 'should destroy genre as admin' do
      sign_in @admin
      assert_difference('Media::Genre.count', -1) do
        delete :destroy, id: @genre
      end
      assert_redirected_to genres_path
    end
  end
end
