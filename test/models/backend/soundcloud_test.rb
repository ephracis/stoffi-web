# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/soundcloud_helper'

class SoundcloudTest < ActiveSupport::TestCase
  include Backends::SoundcloudTestHelpers

  test 'should get songs' do
    stub_soundcloud_song id: '123', playback_count: 42, duration: 54_321
    songs = Backends::Soundcloud.get_songs(%w(123 456))
    assert_equal 2, songs.count, "Didn't get the correct number of songs"
    assert_equal 42, songs[0][:source][:popularity],
                 "Didn't get the correct popularity"
    assert_equal 54_321 / 1000.0, songs[1][:source][:length],
                 "Didn't get the correct length"
  end

  test 'search for songs' do
    stub_soundcloud_search 'song', [
      { playback_count: 42, artwork_url: 'https://art.jpg',
        title: 'Test Artist - Test Song' },
      {}, {}
    ]
    hits = Backends::Soundcloud.search('foo', 'songs')
    assert_equal 3, hits.length, "Didn't return all hits"
    assert_equal 'Test Song', hits[0][:title], "Didn't set name"
    assert_equal [{ name: 'Test Artist' }], hits[0][:artists],
                 "Didn't set artists"
    assert_equal 42, hits[0][:source][:popularity],
                 "Didn't set popularity"
    assert_equal 'https://art.jpg', hits[0][:images][0][:url],
                 "Didn't set image url"
  end

  test 'should generate song' do
    stub_soundcloud_song title: 'Test Song'
    backend = Backends::Soundcloud.new('Media::Song', '123')
    song = backend.generate_resource
    clean_resource_hash!(song)
    assert_difference 'Media::Song.count', 1, "Didn't create new song" do
      song = Media::Song.find_or_create_by_hash(song)
      assert_equal 'Test Song', song.title, "Didn't set correct title"
    end
  end

  test 'should create song from search' do
    stub_soundcloud_search 'song', title: 'Test Song 1'

    songs = Backends::Soundcloud.search 'test query', 'songs'
    song = clean_resource_hash(songs[0])

    assert_difference 'Media::Song.count', 1, "Didn't create new song" do
      song = Media::Song.find_or_create_by_hash(song)
      assert_equal 'Test Song 1', song.title, "Didn't set correct title"
    end
  end
end
