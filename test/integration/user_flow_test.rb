require 'test_helper'

class UserFlowTest < ActionDispatch::IntegrationTest
  fixtures :users
  
  def set_pass(user, passwd)
    params = { password: passwd, password_confirmation: passwd }
    assert user.update_with_password(params), "Could not change password"
    assert user.valid_password?(passwd), "Password did not change properly"
  end
  
  test "login and browse" do
    get new_user_session_path
    assert_response :success
    
    user = users(:alice)
    passwd = "foobar"
    set_pass(user, passwd)
    
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    assert_equal dashboard_path, path
    
    get user_path(user)
    assert_response :success
    assert assigns(:user)
    assert_equal assigns(:user).id, user.id
  end
  
  test "login and continue" do
    get new_user_session_path, {}, {'HTTP_REFERER' => about_path}
    assert_response :success
    
    user = users(:alice)
    passwd = "foobar"
    set_pass(user, passwd)
    
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    assert_equal about_path, path
  end
  
  test "redirect to login and continue" do
    user = users(:alice)
    passwd = "foobar"
    
    get_via_redirect dashboard_path
    assert_response :success
    assert_equal new_user_session_path, path
    
    # referer isn't set yet so we need to re-request with the header
    get new_user_session_path, {}, {'HTTP_REFERER' => dashboard_path}
    assert session['user_return_to'], "Return path not set"
    
    set_pass(user, passwd)
    
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    assert_equal dashboard_path, path
  end
  
  test "fail login with wrong password" do
    get new_user_session_path
    assert_response :success
    
    user = users(:alice)
    passwd = "foobar"
    
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    assert_equal new_user_session_path, path
    assert_equal "Invalid email or password.", flash[:alert]
  end
  
  test "fail login with wrong email" do
    get new_user_session_path
    assert_response :success
    
    user = users(:alice)
    passwd = "foobar"
    set_pass(user, passwd)
    
    post_via_redirect new_user_session_path, user: { email: "foobar", password: passwd }
    assert_equal new_user_session_path, path
    assert_equal "Invalid email or password.", flash[:alert]
  end
  
  test "logout" do
    user = users(:alice)
    passwd = "foobar"
    set_pass(user, passwd)
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    
    get_via_redirect destroy_user_session_path
    assert_response :success
    assert_equal new_user_session_path, path
    
    get dashboard_path
    assert_response :redirect
  end
  
  test "logout and continue" do
    user = users(:alice)
    passwd = "foobar"
    set_pass(user, passwd)
    post_via_redirect new_user_session_path, user: { email: user.email, password: passwd }
    
    get_via_redirect destroy_user_session_path, {}, {'HTTP_REFERER' => about_path}
    assert_response :success
    assert_equal about_path, path
  end
end
