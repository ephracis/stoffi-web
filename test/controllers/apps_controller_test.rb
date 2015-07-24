require 'test_helper'

class AppsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin = User.where(admin: true).first
    @user = User.where(admin: false).first
    @app = apps(:myapp)
    @app_params = {
      name: randstr,
      website: "http://www.#{randstr(lower: true)}.com",
      support_url: "http://www.#{randstr(lower: true)}.com/support",
      callback_url: "http://www.#{randstr(lower: true)}.com/callback",
      key: randstr(lower: true, number: true),
      secret: randstr(lower: true, number: true),
      icon_16: "http://www.#{randstr(lower: true)}.com/img.jpg",
      icon_64: "http://www.#{randstr(lower: true)}.com/img.jpg",
      description: randstr,
      author: randstr,
      author_url: "http://www.#{randstr(lower: true)}.com"
    }

  end

  test "should get index logged in" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:apps)
    assert_not_nil assigns(:added)
    assert_not_nil assigns(:created)
  end

  test "should get index logged out" do
    get :index
    assert_response :success
    assert_not_nil assigns(:apps)
    assert_nil assigns(:added)
    assert_nil assigns(:created)
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, id: @app
    assert_response :success
  end
  
  test "should get show logged out" do
    get :show, id: @app
    assert_response :success
  end
  
  test "should not show missing" do
    get :show, id: "foobar"
    assert_response :not_found
  end
  
  test "should get new logged in" do
    sign_in @user
    get :new
    assert_response :success
  end
  
  test "should not get new logged out" do
    get :new
    assert_redirected_to new_user_session_path
  end
  
  test "should not create logged out" do
    assert_no_difference('App.count') do
      post :create, app: @app_params
    end
    assert_redirected_to new_user_session_path
  end
  
  test "should create as user" do
    sign_in @user
    assert_difference('App.count') do
      post :create, app: @app_params
    end
    assert_redirected_to app_path(assigns(:app))
  end
  
  test "should not get edit logged out" do
    post :edit, id: @app
    assert_redirected_to new_user_session_path
  end
  
  test "should not get edit as user" do
    @app.user = users(:charlie)
    @app.save
    sign_in users(:bob)
    post :edit, id: @app
    assert_redirected_to dashboard_path
  end
  
  test "should get edit as owner" do
    @app.user = users(:charlie)
    @app.save
    sign_in @app.user
    post :edit, id: @app
    assert_response :success
  end
  
  test "should get edit as admin" do
    @app.user = users(:charlie)
    @app.save
    sign_in @admin
    post :edit, id: @app
    assert_response :success
  end
  
  test "should not update logged out" do
    patch :update, id: @app, app: { name: 'New name' }
    assert_redirected_to new_user_session_path
    assert_not_equal 'New name', App.find(@app.id).name, "Changed name"
  end
  
  test "should not update as user" do
    @app.user = users(:charlie)
    @app.save
    sign_in users(:bob)
    patch :update, id: @app, app: { name: 'New name' }
    assert_redirected_to dashboard_path
    assert_not_equal 'New name', App.find(@app.id).name, "Changed name"
  end
  
  test "should update as owner" do
    @app.user = users(:charlie)
    @app.save
    sign_in @app.user
    patch :update, id: @app, app: { name: 'New name' }
    assert_redirected_to app_path(assigns(:app))
    assert_equal 'New name', App.find(@app.id).name, "Didn't change name"
  end
  
  test "should update as admin" do
    sign_in @admin
    patch :update, id: @app, app: { name: 'New name' }
    assert_redirected_to app_path(assigns(:app))
    assert_equal 'New name', App.find(@app.id).name, "Didn't change name"
  end
  
  test "should not destroy logged out" do
    assert_no_difference('App.count') do
      delete :destroy, id: @app
    end
    assert_redirected_to new_user_session_path
  end
  
  test "should not destroy as user" do
    @app.user = users(:charlie)
    @app.save
    sign_in users(:bob)
    assert_no_difference('App.count') do
      delete :destroy, id: @app
    end
    assert_redirected_to dashboard_path
  end
  
  test "should destroy as owner" do
    @app.user = users(:charlie)
    @app.save
    sign_in @app.user
    assert_difference('App.count', -1) do
      delete :destroy, id: @app
    end
    assert_redirected_to apps_path
  end
  
  test "should destroy as admin" do
    sign_in @admin
    assert_difference('App.count', -1) do
      delete :destroy, id: @app
    end
    assert_redirected_to apps_path
  end
  
end
