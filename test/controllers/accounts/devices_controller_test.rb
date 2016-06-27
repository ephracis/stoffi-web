require 'test_helper'

class Accounts::DevicesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @device = accounts_devices(:bob_pc)
    @admin = users(:alice)
    @user = users(:bob)
  end

  test "should not get index" do
    assert_raises ActionController::UrlGenerationError do
      get :index
    end
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, id: @device, user_slug: @device.user
    assert_response :success
  end
  
  test "should not get show logged out" do
    get :show, id: @device, user_slug: @device.user
    assert_redirected_to new_user_session_path
  end
  
  test "should not show missing" do
    sign_in @user
    get :show, id: randstr(special: false), user_slug: @user
    assert_response :not_found
  end

  test "should not get new" do
    assert_raises AbstractController::ActionNotFound do
      get :new, user_slug: @user
    end
  end
  
  test "should not create logged out" do
    assert_no_difference('Accounts::Device.count') do
      post :create, user_slug: @device.user, device: { name: randstr }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create as user" do
    sign_in @user
    assert_difference('Accounts::Device.count') do
      post :create, user_slug: @user,
        device: { name: randstr, app_id: App.first.id }
    end
    assert_redirected_to device_path(assigns(:device))
  end

  test "should not get edit" do
    assert_raises AbstractController::ActionNotFound do
      get :edit, user_slug: @device.user, id: @device
    end
  end

  test "should not update when logged out" do
    new_name = randstr
    patch :update, user_slug: @device.user, id: @device,
      device: { name: new_name }
    assert_redirected_to new_user_session_path
    assert_not_equal new_name, Accounts::Device.find(@device.id).name,
      "Changed name"
  end

  test "should update as owner" do
    sign_in @user
    patch :update, user_slug: @device.user, id: @device,
      device: { name: 'New name' }
    assert_redirected_to device_path(assigns(:device))
    assert_equal 'New name', Accounts::Device.find(@device.id).name,
      "Didn't change name"
  end

  test "should not update someone elses" do
    sign_in @user
    patch :update, user_slug: @device.user, id: @admin.devices.first,
      device: { name: 'New name' }
    assert_redirected_to dashboard_path
    assert_not_equal 'New name',
      Accounts::Device.find(@admin.devices.first.id).name, "Changed name"
  end

  test "should update as admin" do
    sign_in @admin
    patch :update, user_slug: @device.user, id: @device,
      device: { name: 'New name' }
    assert_redirected_to device_path(assigns(:device))
    assert_equal 'New name', Accounts::Device.find(@device.id).name,
      "Didn't change name"
  end

  test "should not destroy when logged out" do
    assert_no_difference('Accounts::Device.count') do
      delete :destroy, id: @device, user_slug: @device.user
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy someone elses" do
    sign_in @user
    assert_no_difference('Accounts::Device.count') do
      delete :destroy, id: @admin.devices.first, user_slug: @device.user
    end
    assert_redirected_to dashboard_path
  end

  test "should destroy as owner" do
    sign_in @user
    assert_difference('Accounts::Device.count', -1) do
      delete :destroy, id: @device, user_slug: @device.user
    end
    assert_redirected_to devices_path
  end

  test "should destroy as admin" do
    sign_in @admin
    assert_difference('Accounts::Device.count', -1) do
      delete :destroy, id: @device, user_slug: @device.user
    end
    assert_redirected_to devices_path
  end
end
