# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/lastfm_helper'
require 'test_helpers/youtube_helper'

class SearchTest < ActiveSupport::TestCase
  include Backends::LastfmTestHelpers
  include Backends::YoutubeTestHelpers

  test 'should get suggestions' do
    s = Search.suggest('bob', '/home', 50, 50, 'us')
    assert_equal 5, s.length, 'Wrong number of suggestions returned'
    assert_equal 'bob marley', s[0][:value].downcase,
                 "First suggestion wasn't correct"
  end

  test "should prioritize user's suggestions" do
    s = Search.suggest('bob', '/home', 50, 50, 'us', [], users(:alice).id)
    assert_equal 5, s.length, 'Wrong number of suggestions returned'
    assert_equal 'Bob Sinclair', s[0][:value],
                 "First suggestion wasn't correct"
  end

  test 'should prioritize nearby suggestions' do
    s = Search.suggest('bob', '/home', 30, 30, 'us')
    assert_equal 5, s.length, 'Wrong number of suggestions returned'
    assert_equal 'Bob Dylan', s[0][:value],
                 "First suggestion wasn't correct"
  end

  test 'should prioritize similar locale suggestions' do
    s = Search.suggest('bob', '/home', 50, 50, 'se')
    assert_equal 5, s.length,
                 'Wrong number of suggestions returned'
    assert_equal 'Bob Andersson', s[0][:value],
                 "First suggestion wasn't correct"
  end

  test 'should prioritize similar page suggestions' do
    s = Search.suggest('bob', '/artists', 50, 50, 'us')
    assert_equal 5, s.length, 'Wrong number of suggestions returned'
    assert_equal 'Bobby Brown', s[0][:value], "First suggestion wasn't correct"
  end

  test 'should get suggestions for artists' do
    s = Search.suggest('bob', '/home', 50, 50, 'us', ['artists'])
    assert_equal 1, s.length, 'Wrong number of suggestions returned'
    assert_equal 'bob marley', s[0][:value].downcase,
                 "First suggestion wasn't correct"
  end

  test 'should get previous search' do
    searches = Search.order(updated_at: :desc)
    s0 = searches[0]
    s1 = searches[1]

    s0.updated_at = 1.second.ago
    s1.updated_at = 5.seconds.ago
    s1.categories = s0.categories
    s1.sources = s0.sources
    s1.query = s0.query
    s0.save!
    s1.save!
    assert_in_delta s1.updated_at, s0.previous_at, 1.second,
                    "Didn't get the correct date"
  end

  test 'should get previous search from first search' do
    searches = Search.order(:updated_at)
    assert searches.first.previous_at < searches.first.updated_at,
           "Didn't get the correct date"
  end

  test 'should search backends for events' do
    stub_lastfm_search 'event', 2
    hits = Search.search_backends('test', 'events', 'lastfm')
    assert_equal 2, hits.length
  end

  test 'should parse search results from backends' do
    stub_lastfm_search 'track', [
      { name: 'Test Lastfm Song', listeners: 123, artist: 'Test Artist',
        image: [{ '#text' => 'http://test.com/test.jpg' }] },
      {}, {}, {}, {}
    ]
    stub_youtube_search 4
    stub_youtube_videos [
      { id: 'id1', snippet: { title: 'Test Song 1' } },
      { id: 'id2', snippet: { title: 'Test Artist - Test Song 2' } },
      { id: 'id3', snippet: { title: 'Test Song 3 by Another Artist' } },
      { id: 'id3', snippet: {
        title: 'Eminem - Test Song 4 feat. Test Artist'
      } }
    ]
    hits = Search.search_backends('test', 'songs', 'lastfm|youtube')
    assert_equal 9, hits.length
    assert_equal 'Test Lastfm Song', hits[0][:title]
    assert_equal 'Test Song 1', hits[5][:title]
    assert_equal 'Test Song 2', hits[6][:title]
    assert_equal 'Test Song 3', hits[7][:title]
    assert_equal 'Test Song 4', hits[8][:title]

    assert_equal 1, hits[0][:artists].length
    assert_equal 'Test Artist', hits[0][:artists][0][:name]
    assert_equal 0, hits[5][:artists].length
    assert_equal 1, hits[6][:artists].length
    assert_equal 'Test Artist', hits[6][:artists][0][:name]
    assert_equal 1, hits[7][:artists].length
    assert_equal 'Another Artist', hits[7][:artists][0][:name]
    assert_equal 2, hits[8][:artists].length
    assert_equal 'Eminem', hits[8][:artists][0][:name]
    assert_equal 'Test Artist', hits[8][:artists][1][:name]
  end
end
