require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  
  test "should get contact" do
    get :contact
    assert_response :success
  end
  
  test "should get legal" do
    get :legal
    assert_response :success
  end
  
  test "should send contact mail" do
    post :mail, name: 'Alice', email: 'alice@mail.com', subject: 'A Title', message: 'my message is not very short'
    assert_redirected_to contact_path
    email = ActionMailer::Base.deliveries.last
    assert_equal ['info@stoffiplayer.com'], email.to
    assert_equal ['alice@mail.com'], email.reply_to
    assert_match /my message is not very short/, email.body.to_s
  end
  
  test "should not get old browser warning on new browsers" do
    new_browsers = [
      'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko', # ie
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko)', # safari
      'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0', # firefox
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36', # chrome
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36', # opera
      
    ].each do |ua|
      cookies.delete(:skip_old)
      @request.headers["HTTP_USER_AGENT"] = ua
      get :about
      assert_response :success
      assert_select 'div#old', false, "Got old browser warning for #{ua}"
    end
  end
  
  test "should get old browser warning" do
    [
      'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)',
      'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/5.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/400.71 (KHTML, like Gecko)'
    ].each do |ua|
      cookies.delete(:skip_old)
      @request.headers["HTTP_USER_AGENT"] = ua
      get :about
      assert_response :success
      assert_select 'div#old', nil, "Didn't get old browser warning for #{ua}"
    end
  end
  
  test "should get pass old browser warning" do
    [
      'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)',
      'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/5.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/400.71 (KHTML, like Gecko)'
    ].each do |ua|
      cookies[:skip_old] = true
      @request.headers["HTTP_USER_AGENT"] = ua
      get :about
      assert_response :success
      assert_select 'div#old', false, "Could not get pass old browser warning on #{ua}"
    end
  end
  
end
