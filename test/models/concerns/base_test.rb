require 'test_helper'

class ConcernBaseTest < ActiveSupport::TestCase
  
  test "should cast to string" do
    assert_equal Media::Song.first.title, Media::Song.first.display
    assert_equal Media::Song.first.title, Media::Song.first.to_s
    assert_equal Media::Artist.first.name, Media::Artist.first.to_s
    assert_equal Media::Playlist.first.name, Media::Playlist.first.to_s
  end
  
end