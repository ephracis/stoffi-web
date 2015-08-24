require 'test_helper'

class Accounts::DevicesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @device = accounts_devices(:bob_pc)
    @admin = users(:alice)
    @user = users(:bob)
  end

  test "should get index logged in" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:devices)
  end

  test "should not get index logged out" do
    get :index
    assert_redirected_to new_user_session_path
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, id: @device
    assert_response :success
  end
  
  test "should not get show logged out" do
    get :show, id: @device
    assert_redirected_to new_user_session_path
  end
  
  test "should not show missing" do
    sign_in @user
    get :show, id: randstr(special: false)
    assert_response :not_found
  end

  test "should not get new" do
    assert_raises AbstractController::ActionNotFound do
      get :new
    end
  end
  
  test "should not create logged out" do
    assert_no_difference('Accounts::Device.count') do
      post :create, device: { name: randstr }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create as user" do
    sign_in @user
    assert_difference('Accounts::Device.count') do
      post :create, device: { name: randstr, app_id: App.first.id }
    end
    assert_redirected_to device_path(assigns(:device))
  end

  test "should not get edit" do
    assert_raises AbstractController::ActionNotFound do
      get :edit, id: @device
    end
  end

  test "should not update when logged out" do
    new_name = randstr
    patch :update, id: @device, device: { name: new_name }
    assert_redirected_to new_user_session_path
    assert_not_equal new_name, Accounts::Device.find(@device.id).name, "Changed name"
  end

  test "should update as owner" do
    sign_in @user
    patch :update, id: @device, device: { name: 'New name' }
    assert_redirected_to device_path(assigns(:device))
    assert_equal 'New name', Accounts::Device.find(@device.id).name, "Didn't change name"
  end

  test "should not update someone elses" do
    sign_in @user
    patch :update, id: @admin.devices.first, device: { name: 'New name' }
    assert_redirected_to dashboard_path
    assert_not_equal 'New name', Accounts::Device.find(@admin.devices.first.id).name, "Changed name"
  end

  test "should update as admin" do
    sign_in @admin
    patch :update, id: @device, device: { name: 'New name' }
    assert_redirected_to device_path(assigns(:device))
    assert_equal 'New name', Accounts::Device.find(@device.id).name, "Didn't change name"
  end

  test "should not destroy when logged out" do
    assert_no_difference('Accounts::Device.count') do
      delete :destroy, id: @device
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy someone elses" do
    sign_in @user
    assert_no_difference('Accounts::Device.count') do
      delete :destroy, id: @admin.devices.first
    end
    assert_redirected_to dashboard_path
  end

  test "should destroy as owner" do
    sign_in @user
    assert_difference('Accounts::Device.count', -1) do
      delete :destroy, id: @device
    end
    assert_redirected_to devices_path
  end

  test "should destroy as admin" do
    sign_in @admin
    assert_difference('Accounts::Device.count', -1) do
      delete :destroy, id: @device
    end
    assert_redirected_to devices_path
  end
end
