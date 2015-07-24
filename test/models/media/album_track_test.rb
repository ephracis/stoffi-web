require 'test_helper'

class AlbumTrackTest < ActiveSupport::TestCase
  
  setup do
    @track = Media::AlbumTrack.new
    @track.album = Media::Album.first
    @track.song = Media::Song.first
    @track.position = 42
  end
  
  test "should create" do
    assert_difference "Media::AlbumTrack.count", +1 do
      @track.save
    end
  end
  
  test "should not create without album" do
    @track.album = nil
    assert_no_difference "Media::AlbumTrack.count" do
      @track.save
    end
  end
  
  test "should not create without song" do
    @track.song = nil
    assert_no_difference "Media::AlbumTrack.count" do
      @track.save
    end
  end
  
end