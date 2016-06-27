require 'test_helper'

class Media::AlbumsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @album = media_albums(:relapse)
    @admin = users(:alice)
    @user = users(:bob)
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'should get index logged in' do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:albums)
  end

  test 'should get index logged out' do
    get :index
    assert_response :success
    assert_not_nil assigns(:albums)
  end

  test 'should get show logged in' do
    sign_in @user
    get :show, id: @album.to_param
    assert_response :success
  end

  test 'should get show logged out' do
    get :show, id: @album.to_param
    assert_response :success
  end

  test 'should not show' do
    get :show, id: 'foobar'
    assert_response :not_found
  end

  test 'should not get new' do
    assert_raises AbstractController::ActionNotFound do
      get :new
    end
  end

  test 'should not create' do
    assert_raises AbstractController::ActionNotFound do
      post :create
    end
  end

  test 'should get edit as admin' do
    sign_in @admin
    get :edit, id: @album.to_param
    assert_response :success
  end

  test 'should not get edit as user' do
    sign_in @user
    get :edit, id: @album.to_param
    assert_redirected_to dashboard_path, 'Not forbidden to edit'
  end

  test 'should not get edit logged out' do
    get :edit, id: @album.to_param
    assert_redirected_to new_user_session_path, 'Not redirected to login page'
  end

  test 'should update as admin' do
    sign_in @admin
    new_title = randstr
    put :update, id: @album.to_param, album: { title: new_title }
    assert_response :found
    assert_redirected_to album_path(assigns(:album))
    assert_equal new_title, Media::Album.find(@album.id).title,
                 "Didn't change title"
  end

  test 'should not update as user' do
    sign_in @user
    put :update, id: @album.to_param, album: { title: randstr }
    assert_redirected_to dashboard_path, 'Not forbidden to edit'
  end

  test 'should not update logged out' do
    put :update, id: @album.to_param, album: { title: randstr }
    assert_redirected_to new_user_session_path, 'Not redirected to login page'
  end

  test 'should destroy as admin' do
    sign_in @admin
    assert_difference('Media::Album.count', -1) do
      delete :destroy, id: @album.to_param
    end
    assert_redirected_to albums_path
  end

  test 'should not destroy as user' do
    sign_in @user
    delete :destroy, id: @album.to_param
    assert_redirected_to dashboard_path, 'Not forbidden to edit'
  end

  test 'should not destroy logged out' do
    delete :destroy, id: @album.to_param
    assert_redirected_to new_user_session_path, 'Not redirected to login page'
  end
end
