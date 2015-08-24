require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  
  %w[400 403 404 422 500 502 503].each do |code|
    test "should show #{code}" do
      get :show, code: code
      assert_response code.to_i
    end
  end
  
end