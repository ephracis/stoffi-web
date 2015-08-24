require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  
  setup do
    @device = Accounts::Device.new
    @device.user = User.first
    @device.app = App.first
    @device.name = randstr
  end
  
  test "should create device" do
    assert_difference "Accounts::Device.count", +1 do
      @device.save
    end
  end
  
  test "should not create without name" do
    @device.name = nil
    assert_no_difference "Accounts::Device.count" do
      @device.save
    end
  end
  
  test "should not create without user" do
    @device.user = nil
    assert_no_difference "Accounts::Device.count" do
      @device.save
    end
  end
  
  test "should not create without app" do
    @device.app = nil
    assert_no_difference "Accounts::Device.count" do
      @device.save
    end
  end
  
  test "should ensure uniqueness of name for user and app" do
    @device.user = Accounts::Device.first.user
    @device.app = Accounts::Device.first.app
    @device.name = Accounts::Device.first.name
    assert_no_difference "Accounts::Device.count" do
      @device.save
    end
  end
  
end