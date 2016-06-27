require 'test_helper'

class Media::EventsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin = users(:alice)
    @user = users(:bob)
    @event = media_events(:festival)
    @event_params = {
      content: randstr,
      start: 3.days.from_now,
      latitude: -1,
      longitude: -1,
      name: randstr,
      category: randstr,
      stop: 4.days.from_now,
      venue: randstr
    }
    Geokit::Geocoders::GoogleGeocoder.stubs(:reverse_geocode).
      returns stub(country_code: 'XX', city: 'Test')
  end

  test "should get index logged in" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end

  test "should get index logged out" do
    get :index
    assert_response :success
    assert_not_nil assigns(:events)
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, id: @event
    assert_response :success
  end
  
  test "should get show logged out" do
    get :show, id: @event
    assert_response :success
  end
  
  test "should not show missing" do
    get :show, id: "foobar"
    assert_response :not_found
  end

  test "should not get new" do
    assert_raises AbstractController::ActionNotFound do
      get :new
    end
  end
  
  test "should not create logged out" do
    assert_no_difference('Media::Event.count') do
      post :create, event: @event_params
    end
    assert_redirected_to new_user_session_path
  end

  test "should create as user" do
    sign_in @user
    assert_difference('Media::Event.count') do
      post :create, event: @event_params
    end
    assert_redirected_to event_path(assigns(:event))
  end

  test "should create as admin" do
    sign_in @admin
    assert_difference('Media::Event.count') do
      post :create, event: @event_params
    end
    assert_redirected_to event_path(assigns(:event))
  end

  test "should not get edit logged out" do
    get :edit, id: @event.to_param
    assert_redirected_to new_user_session_path
  end

  test "should not get edit as user" do
    sign_in @user
    get :edit, id: @event.to_param
    assert_redirected_to dashboard_path
  end

  test "should get edit as admin" do
    sign_in @admin
    get :edit, id: @event.to_param
    assert_response :success
  end

  test "should not update logged out" do
    patch :update, id: @event, event: { name: randstr }
    assert_redirected_to new_user_session_path
    assert_not_equal 'New name', Media::Event.find(@event.id).name, "Changed name"
  end

  test "should not update as user" do
    sign_in @user
    new_name = randstr
    patch :update, id: @event, event: { name: new_name }
    assert_redirected_to dashboard_path
    assert_not_equal new_name, Media::Event.find(@event.id).name, "Changed name"
  end

  test "should update as admin" do
    sign_in @admin
    new_name = randstr
    patch :update, id: @event, event: { name: new_name }
    assert_redirected_to event_path(assigns(:event))
    assert_equal new_name, Media::Event.find(@event.id).name, "Didn't change name"
  end

  test "should not destroy logged out" do
    assert_no_difference('Media::Event.count') do
      delete :destroy, id: @event
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy as user" do
    sign_in @user
    assert_no_difference('Media::Event.count') do
      delete :destroy, id: @event
    end
    assert_redirected_to dashboard_path
  end

  test "should destroy as admin" do
    sign_in @admin
    assert_difference('Media::Event.count', -1) do
      delete :destroy, id: @event
    end
    assert_redirected_to events_path
  end
end
