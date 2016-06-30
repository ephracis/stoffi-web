# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/youtube_helper'

class YoutubeTest < ActiveSupport::TestCase
  include Backends::YoutubeTestHelpers

  test 'should get songs' do
    stub_youtube_videos [
      { id: 'id1', statistics: { viewCount: 20_882_668 },
        contentDetails: { duration: 'PT7M9S' } },
      { id: 'id2', statistics: { viewCount: 60_107_360 },
        contentDetails: { duration: 'PT7M20S' } }
    ]

    songs = Backends::Youtube.get_songs(%w(id1 id2))

    assert_equal 2, songs.count, "Didn't get the correct number of songs"
    assert_equal 20_882_668, songs[0][:source][:popularity],
                 "Didn't get the correct popularity for id1"
    assert_equal 60_107_360, songs[1][:source][:popularity],
                 "Didn't get the correct popularity for id2"
    assert_equal 7 * 60 + 9,  songs[0][:source][:length],
                 "Didn't get the correct length for id1"
    assert_equal 7 * 60 + 20, songs[1][:source][:length],
                 "Didn't get the correct length for id2"
  end

  test 'should search for songs' do
    stub_youtube_search 3
    stub_youtube_videos [
      { id: 'id1', snippet: { title: 'Test Song 1' } },
      { id: 'id2', snippet: { title: 'Test Song 2' } },
      { id: 'id3', snippet: { title: 'Test Song 3' } }
    ]

    songs = Backends::Youtube.search 'test query', 'songs'

    assert_equal 3, songs.count,
                 "Didn't return the correct number of search hits"
    assert_equal 'Test Song 1', songs[0][:title]
    assert_equal 'Test Song 2', songs[1][:title]
    assert_equal 'Test Song 3', songs[2][:title]
  end

  test 'should generate song' do
    stub_youtube_video snippet: { title: 'Test Song' }
    backend = Backends::Youtube.new('Song', 'id1')
    song = backend.generate_resource
    clean_resource_hash! song
    assert_difference 'Media::Song.count', 1, "Didn't create new song" do
      song = Media::Song.find_or_create_by_hash(song)
      assert_equal 'Test Song', song.title, "Didn't set correct title"
    end
  end

  test 'should create song from search' do
    stub_youtube_search 1
    stub_youtube_video snippet: { title: 'Test Song 1' }

    songs = Backends::Youtube.search 'test query', 'songs'
    song = clean_resource_hash(songs[0])

    assert_difference 'Media::Song.count', 1, "Didn't create new song" do
      song = Media::Song.find_or_create_by_hash(song)
      assert_equal 'Test Song 1', song.title, "Didn't set correct title"
    end
  end
end
