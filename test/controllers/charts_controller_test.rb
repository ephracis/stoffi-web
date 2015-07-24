require 'test_helper'

class ChartsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin = users(:alice)
    @user = users(:bob)
  end
  
  %w[listens_for_user songs_for_user artists_for_user albums_for_user genres_for_user playlists_for_user top_listeners].each do |chart|

    test "should not get #{chart} logged out" do
      get chart, format: :json
      assert_response :unauthorized
    end

    test "should get #{chart} logged in" do
      sign_in @user
      get chart, format: :json
      assert_response :success
    end
  end
  
  %w[active_users].each do |chart|

    test "should not get #{chart} logged out" do
      get chart, format: :json
      assert_response :unauthorized
    end

    test "should not get #{chart} as user" do
      sign_in @user
      get chart, format: :json
      assert_response :forbidden
    end

    test "should get #{chart} as admin" do
      sign_in @admin
      get chart, format: :json
      assert_response :success
    end
    
  end
  
end