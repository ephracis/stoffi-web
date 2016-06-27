require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  
  setup do
    @share = Share.new
    @share.resource = Media::Song.first
    @share.user = User.first
  end
  
  test "should create" do
    assert_difference "Share.count", +1 do
      @share.save
    end
  end
  
  test "should not create without resource" do
    @share.resource = nil
    assert_no_difference "Share.count" do
      @share.save
    end
  end
  
  test "should not create without user" do
    @share.user = nil
    assert_no_difference "Share.count" do
      @share.save
    end
  end
  
end