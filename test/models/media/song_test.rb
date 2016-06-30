# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/youtube_helper'
require 'test_helpers/soundcloud_helper'

class SongTest < ActiveSupport::TestCase
  include Backends::YoutubeTestHelpers
  include Backends::SoundcloudTestHelpers

  test 'should create song' do
    assert_difference('Media::Song.count', 1, "Didn't create song") do
      Media::Song.create(title: 'a random title')
    end
  end

  test 'should not create song without title' do
    assert_no_difference('Media::Song.count', 'Created song without title') do
      Media::Song.create
    end
  end

  test 'should get youtube song' do
    stub_youtube_video snippet: { title: 'SomeTitle' }
    assert_difference('Media::Song.count', 1, "Didn't create song") do
      s = Media::Song.find_or_create_by_path 'stoffi:song:youtube:123'
      assert_equal 'SomeTitle', s.title, "Didn't set the correct title"
    end
  end

  test 'should get new soundcloud song' do
    stub_soundcloud_song title: 'SomeTitle'
    assert_difference('Media::Song.count', 1, "Didn't create song") do
      s = Media::Song.find_or_create_by_path 'stoffi:song:soundcloud:abc'
      assert_equal 'SomeTitle', s.title, "Didn't set the correct title"
    end
  end

  test 'should get existing song with same artists and title' do
    song = media_songs(:not_afraid)

    # make sure we don't go by just title
    song_2 = media_songs(:one_love)
    song_2.title = song.title
    song_2.save

    assert_no_difference('Media::Song.count', 'Created song') do
      s = Media::Song.find_or_create_by_hash(
        title: song.title.upcase,
        artists: song.artists.map { |x| { name: x.name.upcase } }
      )
      assert_equal song.id, s.id, "Didn't return the existing song"
    end
  end

  test 'should get existing youtube song' do
    song = media_songs(:one_love)
    src = song.sources.first
    path = "stoffi:song:#{src.name}:#{src.foreign_id}"
    assert_no_difference('Media::Song.count', 'Created song') do
      s = Media::Song.find_or_create_by_path path
      assert_equal song.id, s.id, "Didn't return the existing song"
    end
  end

  test 'should get song from search result' do
    hit = {
      fullname: 'Eminem - Relapse',
      title: 'Relapse',
      artists: [{ name: 'Eminem' }],
      source: {
        name: :youtube,
        foreign_id: 'foo',
        popularity: 123,
        length: 92
      }
    }
    s = nil
    assert_difference('Media::Song.count', 1, "Didn't create song") do
      s = Media::Song.find_or_create_by_hash hit
    end
    assert_equal hit[:title], s.title, "Didn't create song with correct title"
    assert_equal hit[:artists].length, s.artists.count,
                 "Didn't assign any artist to song"
    assert_equal hit[:artists][0][:name], s.artists[0].name,
                 "Didn't assign song to correct artist"
    assert_equal hit[:source][:popularity], s.sources[0].popularity,
                 "Didn't assign correct popularity"
    assert_equal hit[:source][:length], s.sources[0].length,
                 "Didn't assign correct length"
  end

  test 'should parse title' do
    [
      'foobar - a great song',
      'foobar - a great song [official]',
      'foobar - a great song (LYRICS)',
      'foobar - a great song official video',
      'a great song by foobar',
      'a great song, by foobar',
      'foobar "a great song"',
      'foobar: a great song',
      '-=foobar=-: __a great song__ (HQ)'
    ].each do |t|
      artists, title = Media::Song.parse_title(t)
      assert_equal 1, artists.length, "Didn't parse out single artist in: #{t}"
      assert_equal 'foobar', artists[0], "Didn't parse out artist in: #{t}"
      assert_equal 'a great song', title, "Didn't parse out title in: #{t}"
    end
  end

  test 'should parse title with multiple artists' do
    [
      'foo - a great song feat. bar + baz',
      'foo & bar - a great song [official] feats baz',
      'foo - a great song (LYRICS) ft. bar&baz',
      'foo + bar + baz - a great song official video',
      'a great song ft baz by foo and bar',
      'foo vs bar und baz "a great song"'
    ].each do |t|
      artists, title = Media::Song.parse_title(t)
      assert_equal 3, artists.length,
                   "Didn't parse out multiple artists in: #{t}"
      assert_includes artists, 'foo', "Didn't parse out artist foo in: #{t}"
      assert_includes artists, 'bar', "Didn't parse out artist bar in: #{t}"
      assert_includes artists, 'baz', "Didn't parse out artist baz in: #{t}"
      assert_equal 'a great song', title, "Didn't parse out title in: #{t}"
    end
  end

  test 'should get top songs' do
    s = Media::Song.rank.limit 3
    assert_equal 3, s.length, "Didn't return three songs"
    assert s[0].listens.count >= s[1].listens.count,
           'Top songs not in order (first and second)'
    assert s[1].listens.count >= s[2].listens.count,
           'Top songs not in order (second and third)'
  end

  test 'should get top songs for artist' do
    s = media_artists(:bob_marley).songs.rank.limit 3
    assert_equal 3, s.length, "Didn't return three songs"
    assert s[0].listens.count >= s[1].listens.count,
           'Top songs not in order (first and second)'
    assert s[1].listens.count >= s[2].listens.count,
           'Top songs not in order (second and third)'
  end

  # test "should set artists" do
  #   eminem = media_artists(:eminem)
  #   coldplay = media_artists(:coldplay)
  #   song = media_songs(:one_love)
  #   song.artists = "#{eminem.name} feat. #{coldplay.name}"
  #   assert_equal 2, song.artists.count, "Didn't split artists string into two"
  #   assert_includes song.artists, eminem,
  #                   "#{eminem.name} was not in collection"
  #   assert_includes song.artists, coldplay,
  #                   "#{coldplay.name} was not in collection"
  # end

  test 'should get similar, same artist' do
    song = media_songs(:no_woman_no_cry)
    song.genres.clear
    song.similar.each do |s|
      assert !(s.artists & song.artists).empty?,
             "#{s} was not made by any of #{song.artists.to_a}"
    end
  end

  test 'should get similar, same album' do
    song = media_songs(:not_afraid)
    song.genres.clear
    song.similar.each do |s|
      assert !(s.albums & song.albums).empty?,
             "#{s} was not in any of #{song.albums.to_a}"
    end
  end

  test 'should get similar, same genre' do
    song = media_songs(:welcome_to_jamrock)
    song.similar.each do |s|
      assert !(s.genres & song.genres).empty?
    end
  end
end
