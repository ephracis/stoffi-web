require 'test_helper'

class GenericBrowsingTest < ActionDispatch::IntegrationTest
  test 'show front page' do
    visit '/'
    assert page.has_link?("About"), "Missing about link"
    assert page.has_link?("Music"), "Missing music link"
    assert page.has_link?("App"), "Missing download link"
    assert page.has_link?("Login"), "Missing login link"
  end
  
  test 'show login page' do
    visit '/login'
    assert page.has_field?("user_email", :type => "email"), "Missing email field"
    assert page.has_field?("user_password", :type => "password"), "Missing password field"
    assert page.has_link?("Join"), "Missing join link"
  end
  
  test 'show join page' do
    visit '/join'
    assert page.has_field?("user_email", :type => "email"), "Missing email field"
    assert page.has_field?("user_password", :type => "password"), "Missing password field"
    assert page.has_field?("user_password_confirmation", :type => "password"), 
      "Missing password confirmation field"
    assert page.has_link?("Login"), "Missing login link"
  end
  
  test 'go to about' do
    visit '/'
    click_on 'About'
  end
end