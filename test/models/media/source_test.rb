# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/youtube_helper'

class SourceTest < ActiveSupport::TestCase
  include Backends::YoutubeTestHelpers

  test 'should parse soundcloud path' do
    p = Media::Source.parse_path('stoffi:song:soundcloud:abc')
    assert_equal 'Media::Song', p[:resource_type]
    assert_equal :soundcloud, p[:name]
    assert_equal 'abc', p[:foreign_id]
  end

  test 'should parse youtube path' do
    p = Media::Source.parse_path('stoffi:playlist:youtube:qwe')
    assert_equal 'Media::Playlist', p[:resource_type]
    assert_equal :youtube, p[:name]
    assert_equal 'qwe', p[:foreign_id]
  end

  test 'should parse url path' do
    p = Media::Source.parse_path('http://foo.com/song.mp3')
    assert_equal 'Media::Song', p[:resource_type]
    assert_equal :url, p[:name]
    assert_equal 'http://foo.com/song.mp3', p[:foreign_id]
  end

  test 'should parse url path without extension' do
    p = Media::Source.parse_path('http://foo.com/song')
    assert_equal 'Media::Song', p[:resource_type]
    assert_equal :url, p[:name]
    assert_equal 'http://foo.com/song', p[:foreign_id]
  end

  test 'should create by path' do
    stub_youtube_video snippet: { title: 'Test Artist - Test Song' }
    assert_difference 'Media::Source.count', 1, "Didn't create new source" do
      s = Media::Source.find_or_create_by_path('stoffi:song:youtube:qwe')
      assert s, "Didn't return source"
      assert_equal 'youtube', s.name, "Didn't set name"
      assert_equal 'qwe', s.foreign_id, "Didn't set id"
      assert s.resource, "Didn't create resource"
      assert_instance_of Media::Song, s.resource, "Didn't create Song resource"
      assert_equal 'Test Song', s.resource.title, "Didn't set song title"
    end
  end

  test 'should find by path' do
    src = media_sources(:no_woman_no_cry_soundcloud)
    path = "stoffi:song:#{src.name}:#{src.foreign_id}"
    s = nil
    assert_no_difference 'Media::Source.count', 'Created new source' do
      s = Media::Source.find_or_create_by_path(path)
    end
    assert s, "Didn't return source"
    assert_equal s, src, "Didn't return the correct source"
  end

  test 'should cast to string' do
    assert_equal 'YouTube', media_sources(:one_love_youtube).to_s
    assert_equal 'SoundCloud', media_sources(:relapse_soundcloud).to_s
    assert_equal 'Last.fm', media_sources(:festival_lastfm).to_s
  end
end
