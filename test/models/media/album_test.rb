require 'test_helper'
require 'test_helpers/youtube_helper'

class AlbumTest < ActiveSupport::TestCase
  
  include Backends::YoutubeTestHelpers
  
  setup do
    path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
    stub_request(:get, 'http://foo.com/img1.jpg').to_return(:body => File.new(path), :status => 200)
    stub_request(:get, 'http://foo.com/img2.jpg').to_return(:body => File.new(path), :status => 200)
    
    @hash = {
      title: 'Foo',
      artists: [ { name: 'Damian Marley' } ],
      source: {
        name: 'lastfm', foreign_id: '123', popularity: '123',
        foreign_url: 'http://foo.com/album1'
      },
      images: [
        { url: 'http://foo.com/img1.jpg' },
        { url: 'http://foo.com/img2.jpg' },
      ]
    }
  end
  
  test "should create album" do
    a = nil
    assert_difference 'Media::Album.count', 1, "Didn't create new album" do
      a = Media::Album.find_or_create_by_hash(@hash)
    end
    assert a, "Didn't return album"
    assert_equal @hash[:title], a.title, "Didn't set title"
    
    assert_equal @hash[:artists][0][:name], a.artists.first.name, "Didn't set artist"
    assert_equal @hash[:images].length, a.images.count, "Didn't set images"
    assert_equal 1, a.sources.count, "Didn't set source"
    
    s = a.sources[0]
    
    assert_equal @hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal @hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal @hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal @hash[:source][:name], s.name, "Didn't set source name"
  end
  
  test 'should not create album without title' do
    assert_no_difference 'Media::Album.count', "Created new album without title" do
      a = Media::Album.create
    end
  end
  
  test "should create album with existing artist" do
    artist = media_artists(:bob_marley)
    a = nil
    @hash[:artists] = [{name: artist.name}]
    assert_no_difference 'Media::Artist.count', "Created new artist" do
      a = Media::Album.find_or_create_by_hash(@hash)
    end
    assert_equal artist, a.artists.first, "Didn't set artist"
  end
  
  test "should find album" do
    album = nil
    a = media_albums(:relapse)
    @hash[:title] = a.title
    @hash.delete(:artist)
    @hash[:artists] = []
    artists_before = a.artists.count
    a.artists.each { |artist| @hash[:artists] << { name: artist.name } }
    assert_no_difference 'Media::Album.count', "Created new album" do
    assert_no_difference 'Media::Artist.count', "Created more artists" do
      album = Media::Album.find_or_create_by_hash(@hash)
    end
    end
    assert_equal a, album, "Didn't return correct album"
    assert_equal artists_before, album.artists.count, "Changed number of artists"
    
    s = a.sources.where(name: :lastfm).first
    assert s, "Didn't set source"
    assert_equal @hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal @hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal @hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal @hash[:source][:name].to_s, s.name, "Didn't set source name"
  end
  
  test "should add songs" do
    stub_youtube_videos snippet: { title: 'Foo - Bar' }
    a = media_albums(:recovery)
    s = media_songs(:not_afraid)
    @hash[:title] = a.title
    @hash[:artists] = [{name: a.artists.first.name}]
    @hash[:songs] = [
      {
        title: s.title, # shouldn't matter
        artists: [{ name: a.artists.first.name }], # shouldn't matter
        path: "stoffi:song:youtube:123"
      },
      { path: s.sources.first.path }
    ]
    album = nil
    assert_difference "Media::Artist.count", 1, "Didn't create exactly one artist" do
    assert_difference "Media::Song.count", 1, "Didn't create exactly one song" do
      album = Media::Album.find_or_create_by_hash(@hash)
    end
    end
    assert_equal 4, album.songs.count, "Didn't assign both songs"
  end

  test "should not re-add existing songs" do
    stub_youtube_videos snippet: { title: 'Foo - Bar' }
    a = media_albums(:recovery)
    s = media_songs(:one_love)
    @hash[:title] = a.title
    @hash[:artists] = [{name: a.artists.first.name}]
    @hash[:songs] = [
      {
        title: s.title, # shouldn't matter
        artists: [{ name: a.artists.first.name }], # shouldn't matter
        path: 'stoffi:song:youtube:123'
      },
      { path: s.sources.first.path }
    ]
    assert_equal 2, a.songs.count, "Didn't start out with 2 songs"
    album = Media::Album.find_or_create_by_hash(@hash)
    assert_equal a, album, "Didn't fetch existing album"
    assert_equal 3, album.songs.count, "Didn't assign the song"
  end
  
  test "should get top albums" do
    a = Media::Album.top limit: 3
    assert_equal 3, a.length, "Didn't return three top albums"
    assert_instance_of Media::Album, a.first, "Didn't return albums"
    assert a[0].listens.count >= a[1].listens.count, "Top albums not in order (first and second)"
    assert a[1].listens.count == a[2].listens.count, "Top albums not in order (second and third, listens)"
    assert a[1].popularity > a[2].popularity, "Top albums not in order (second and third, popularity)"
  end
  
  test "should get popularity" do
    a = media_albums(:best_of_bob_marley)
    p = 0
    a.songs.each do |s|
      s.sources.each do |src|
        p += src.normalized_popularity
      end
    end
    assert_equal p, a.popularity, "Popularity isn't the combined popularity of the songs"
    
    a = media_albums(:recovery)
    p = 0
    a.sources.each do |s|
      p += s.normalized_popularity
    end
    assert_equal p, a.popularity, "Popularity isn't the combined popularity of the sources"
  end
  
  test 'should get artist names' do
    a = media_albums(:relapse)
    assert_equal 'Bob Marley and Eminem', a.artist_names
  end
end
