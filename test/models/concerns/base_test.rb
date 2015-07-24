require 'test_helper'

class ConcernBaseTest < ActiveSupport::TestCase
  
  test "should cast to string" do
    assert_equal Media::Song.first.title, Media::Song.first.display
    assert_equal Media::Song.first.title, Media::Song.first.to_s
    assert_equal Media::Artist.first.name, Media::Artist.first.to_s
    assert_equal Media::Playlist.first.name, Media::Playlist.first.to_s
  end
  
  test "should display pretty params" do
    x = Media::Song.first
    x.title = 'foo'
    assert 'foo'.in?(x.to_param)
    
    x = Media::Playlist.first
    x.name = 'foo'
    assert 'foo'.in?(x.to_param)
  end
  
  test "should fall back to id for param when display is blank" do
    x = Media::Playlist.first
    x.name = ''
    assert_equal x.id.to_s, x.to_param
  end
  
end