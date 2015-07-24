require 'test_helper'
require 'test_helpers/lastfm_helper'

class LastfmTest < ActiveSupport::TestCase
  
  include Backends::LastfmTestHelpers
  
  test 'search for artists' do
    stub = stub_lastfm_search 'artist', [
      { name: 'Test Artist', listeners: 123, image: [ { '#text' => 'http://test.com/test.jpg' }]},
      {}, {}, {}, {}
    ]
    hits = Backends::Lastfm.search('foo', 'artists')
    assert_equal 5, hits.length, "Didn't return all hits"
    assert_equal 'Test Artist', hits[0][:name], "Didn't set name"
    assert_equal 123, hits[0][:source][:popularity], "Didn't set popularity"
    assert_equal 'http://test.com/test.jpg', hits[0][:images][0][:url], "Didn't set image url"
    remove_request_stub(stub)
  end
  
  test 'search for albums' do
    stub = stub_lastfm_search 'album', [
      { name: 'Test Album', artist: 'Test Artist', image: [ { '#text' => 'http://test.com/test.jpg' }]},
      {}, {}, {}, {}
    ]
    hits = Backends::Lastfm.search('foo', 'albums')
    assert_equal 5, hits.length, "Didn't return all hits"
    assert_equal 'Test Album', hits[0][:title], "Didn't set name"
    assert_equal 'Test Artist', hits[0][:artists][0][:name], "Didn't set artist"
    assert_equal 'http://test.com/test.jpg', hits[0][:images][0][:url], "Didn't set image url"
    remove_request_stub(stub)
  end
 
  test 'search for songs' do
    stub = stub_lastfm_search 'track', [
      { name: 'Test Track', listeners: 123, artist: 'Test Artist', image: [ { '#text' => 'http://test.com/test.jpg' }]},
      {}, {}, {}, {}
    ]
    hits = Backends::Lastfm.search('foo', 'songs')
    assert_equal 5, hits.length, "Didn't return all hits"
    assert_equal "Test Track", hits[0][:title], "Didn't set name"
    assert_equal 123, hits[0][:source][:popularity], "Didn't set popularity"
    assert_equal "Test Artist", hits[0][:artists][0][:name], "Didn't set artist"
    assert_equal "http://test.com/test.jpg", hits[0][:images][0][:url], "Didn't set image url"
    remove_request_stub(stub)
  end
    
  test 'search for events' do
    stub = stub_lastfm_search 'event', [
      {
        title: 'Test Event',
        attendance: 123,
        artists: {
          artist: ['Artist1', 'Artist2'],
          headliner: 'Artist1'
        },
        venue: {
          location: {
            'geo:point' => { 'geo:lat' => 1.23 },
            city: 'Test City'
          },
        },
        image: [ { '#text' => 'http://test.com/test.jpg' }]
      },
      {}, {}, {}, {} # + 4 more random events
    ]
    hits = Backends::Lastfm.search('foo', 'events')
    assert_equal 5, hits.length, "Didn't return all hits"
    assert_equal "Test Event", hits[0][:name], "Didn't set name"
    assert_equal 123, hits[0][:source][:popularity], "Didn't set popularity"
    assert_includes hits[0][:artists], {name: 'Artist1'}, "Didn't set artists"
    assert_includes hits[0][:artists], {name: 'Artist2'}, "Didn't set artists"
    assert_equal 1.23, hits[0][:latitude], "Didn't set location"
    assert_equal 'Test City', hits[0][:venue], "Didn't set city"
    assert_equal 'http://test.com/test.jpg', hits[0][:images][0][:url], "Didn't set image url"
    remove_request_stub(stub)
  end
  
  test 'search for artists and albums' do
    stub = stub_lastfm_search 'artist', 3
    stub_lastfm_search 'album', 5
    hits = Backends::Lastfm.search('foo', 'artists|albums')
    assert_equal 8, hits.length, "Didn't return all hits"
    remove_request_stub(stub)
  end
  
  test 'get info for artist' do
    stub = stub_lastfm_info 'artist', { name: 'Test Artist' }
    x = Backends::Lastfm.get_info('foo', 'artist')
    assert x, "Didn't return anything"
    assert_equal 'Test Artist', x[:name], "Didn't set name"
    remove_request_stub(stub)
  end

  test 'get info for album' do
    stub = stub_lastfm_info 'album', { name: 'Test Album' }
    x = Backends::Lastfm.get_info("foo\tfoo", 'album')
    assert x, "Didn't return anything"
    assert_equal 'Test Album', x[:title], "Didn't set name"
    remove_request_stub(stub)
  end
  
  test 'get info for song' do
    stub = stub_lastfm_info 'track', { name: 'Test Track' }
    x = Backends::Lastfm.get_info("foo\tfoo", 'song')
    assert x, "Didn't return anything"
    assert_equal "Test Track", x[:title], "Didn't set name"
    remove_request_stub(stub)
  end
  
  test 'get info for event' do
    stub = stub_lastfm_info 'event', { title: 'Test Event' }
    x = Backends::Lastfm.get_info('foo', 'event')
    assert x, "Didn't return anything"
    assert_equal 'Test Event', x[:name], "Didn't set name"
    remove_request_stub(stub)
  end
  
  test 'get info for invalid artist' do
    stub = stub_lastfm_invalid 'artist'
    x = Backends::Lastfm.get_info('bar', 'artist')
    assert !x, "Returned something"
    remove_request_stub(stub)
  end
  
  test 'get info for invalid album' do
    stub = stub_lastfm_invalid 'album'
    x = Backends::Lastfm.get_info("bar\tfoo", 'album')
    assert !x, "Returned something"
    remove_request_stub(stub)
  end
  
  test 'get info for invalid song' do
    stub = stub_lastfm_invalid 'track'
    x = Backends::Lastfm.get_info("bar\tfoo", 'song')
    assert !x, "Returned something"
    remove_request_stub(stub)
  end
  
  test "get info for invalid song's artist" do
    stub = stub_lastfm_invalid 'track'
    x = Backends::Lastfm.get_info("bar\tbar", 'song')
    assert !x, "Returned something"
    remove_request_stub(stub)
  end
  
  test 'get info for invalid event' do
    stub = stub_lastfm_invalid 'event'
    x = Backends::Lastfm.get_info('bar', 'event')
    assert !x, "Returned something"
    remove_request_stub(stub)
  end
  
  test 'should generate song' do
    stub = stub_lastfm_info 'track', { name: 'Test Song' }
    backend = Backends::Lastfm.new('Song', "foo\tbar")
    x = backend.generate_resource
    x = clean_resource_hash(x)
    
    assert_difference "Media::Song.count", 1, "Didn't create new song" do
      x = Media::Song.find_or_create_by_hash(x)
      assert_equal 'Test Song', x.title, "Didn't set correct title"
    end
    remove_request_stub(stub)
  end
  
  test 'should generate album' do
    stub = stub_lastfm_info 'album', { name: 'Test Album' }
    backend = Backends::Lastfm.new('Album', "foo\tbar")
    x = backend.generate_resource
    x = clean_resource_hash(x)
    
    assert_difference "Media::Album.count", 1, "Didn't create new album" do
      x = Media::Album.find_or_create_by_hash(x)
      assert_equal 'Test Album', x.title, "Didn't set correct title"
    end
    remove_request_stub(stub)
  end
  
  test 'should generate artist' do
    stub = stub_lastfm_info 'artist', { name: 'Test Artist' }
    backend = Backends::Lastfm.new('Artist', "foo")
    x = backend.generate_resource
    x = clean_resource_hash(x)
    
    assert_difference "Media::Artist.count", 1, "Didn't create new artist" do
      x = Media::Artist.find_or_create_by_hash(x)
      assert_equal 'Test Artist', x.name, "Didn't set correct name"
    end
    remove_request_stub(stub)
  end
  
  test 'should generate event' do
    stub = stub_lastfm_info 'event', { title: 'Test Event' }
    backend = Backends::Lastfm.new('Event', "foo")
    x = backend.generate_resource
    x = clean_resource_hash(x)
    
    assert_difference "Media::Event.count", 1, "Didn't create new event" do
      x = Media::Event.find_or_create_by_hash(x)
      assert_equal 'Test Event', x.name, "Didn't set correct name"
    end
    remove_request_stub(stub)
  end
  
  test 'should create artist from search' do
    stub = stub_lastfm_search 'artist', { name: 'Test Artist' }
    
    hits = Backends::Lastfm.search 'test query', 'artists'
    x = clean_resource_hash(hits[0])
    
    assert_difference "Media::Artist.count", 1, "Didn't create new artist" do
      x = Media::Artist.find_or_create_by_hash(x)
      assert_equal 'Test Artist', x.name, "Didn't set correct name"
    end
    
    remove_request_stub(stub)
  end
  
  test 'should create song from search' do
    stub = stub_lastfm_search 'track', { name: 'Test Song' }
    
    hits = Backends::Lastfm.search 'test query', 'songs'
    x = clean_resource_hash(hits[0])
    
    assert_difference "Media::Song.count", 1, "Didn't create new song" do
      x = Media::Song.find_or_create_by_hash(x)
      assert_equal 'Test Song', x.title, "Didn't set correct title"
    end
    
    remove_request_stub(stub)
  end
  
  test 'should create album from search' do
    stub = stub_lastfm_search 'album', { name: 'Test Album' }
    
    hits = Backends::Lastfm.search 'test query', 'albums'
    x = clean_resource_hash(hits[0])
    
    assert_difference "Media::Album.count", 1, "Didn't create new album" do
      x = Media::Album.find_or_create_by_hash(x)
      assert_equal 'Test Album', x.title, "Didn't set correct title"
    end
    
    remove_request_stub(stub)
  end
  
  test 'should create event from search' do
    stub = stub_lastfm_search 'event', { title: 'Test Event' }
    
    hits = Backends::Lastfm.search 'test query', 'events'
    x = clean_resource_hash(hits[0])
    
    assert_difference "Media::Event.count", 1, "Didn't create new event" do
      x = Media::Event.find_or_create_by_hash(x)
      assert_equal 'Test Event', x.name, "Didn't set correct title"
    end
    
    remove_request_stub(stub)
  end
  
  test "should start listen" do
    listen = media_listens(:alice_one_love)
    link = accounts_links(:alice_lastfm)
    params = {
      artist: listen.song.artist_names,
      track: listen.song.title,
      duration: listen.song.length.to_i.to_s,
      timestamp: listen.created_at.to_i.to_s,
      method: "track.updateNowPlaying"
    }
    
    params[:api_key] = Rails.application.secrets.oa_cred['lastfm']['id']
    secret = Rails.application.secrets.oa_cred['lastfm']['key']
    params[:sk] = link.access_token
    params[:api_sig] = Digest::MD5.hexdigest(params.stringify_keys.sort.flatten.join + secret)
    params[:format] = "json"
    url = "http://ws.audioscrobbler.com/2.0/"
    
    stub_request(:post, url).with(body: params).to_return(body: { "a" => "b" }.to_json)
    link.start_listen(listen)
  end
  
  test "should end listen" do
    listen = media_listens(:alice_one_love)
    link = accounts_links(:alice_lastfm)
    params = {
      artist: listen.song.artist_names,
      track: listen.song.title,
      duration: listen.song.length.to_i.to_s,
      timestamp: listen.created_at.to_i.to_s,
      method: "track.scrobble"
    }
    
    params[:api_key] = Rails.application.secrets.oa_cred['lastfm']['id']
    secret = Rails.application.secrets.oa_cred['lastfm']['key']
    params[:sk] = link.access_token
    params[:api_sig] = Digest::MD5.hexdigest(params.stringify_keys.sort.flatten.join + secret)
    params[:format] = "json"
    url = "http://ws.audioscrobbler.com/2.0/"
    
    stub_request(:post, url).with(body: params).to_return(body: { "a" => "b" }.to_json)
    link.end_listen(listen)
  end
  
end
