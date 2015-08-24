require 'test_helper'

class DuplicatableTest < ActiveSupport::TestCase
  
  test "should filter" do
    artist = media_artists(:bob_marley)
    master = media_songs(:one_love)
    dup = Media::Song.create(title: 'One Love / People Get Ready')
    assert_difference "artist.songs.count", +1 do
      dup.artists << artist
    end
    
    assert_difference "artist.songs.count", -1 do
    assert_no_difference "artist.songs.unscoped.count" do
      dup.duplicate_of master
    end
    end
  end
  
  test "should be transitive" do
    a = media_artists(:eminem)
    b = media_artists(:bob_marley)
    c = media_artists(:damian_marley)
    d = media_artists(:coldplay)
    
    a.duplicate_of b
    b.duplicate_of c
    c.duplicate_of d
    
    assert_equal d, a.archetype
    assert_equal 3, d.duplicates.count
  end
  
  test "should be marked as duplicate" do
    a = media_albums(:relapse)
    b = media_albums(:recovery)
    
    assert_not a.duplicate?, "a marked as duplicate"
    a.duplicate_of b
    assert a.duplicate?, "a not marked as duplicate"
    assert a.duplicate_of?(b), "a not marked as duplicate of b"
    assert_not b.duplicate_of?(a), "b marked as duplicate of a"
  end
  
  test "should count duplicates" do
    a = media_songs(:one_love)
    b = media_songs(:not_afraid)
    c = media_songs(:no_woman_no_cry)
    
    assert_equal 0, c.duplicates.count
    
    assert_difference "c.duplicates.count", +1 do
      a.duplicate_of c
    end
    
    assert_difference "c.duplicates.count", +1 do
      b.duplicate_of c
    end
  end
  
  test "should combine has_many relation" do
    a = media_songs(:one_love)
    b = media_songs(:not_afraid)
    combined = a.listens.count + b.listens.count
    a.duplicate_of b
    
    assert_equal 1, b.duplicates.length
    assert_equal combined, b.listens.count
  end
  
  test "should combine has_many :as relation" do
    a = media_songs(:one_love)
    b = media_songs(:not_afraid)
    combined = a.shares.count + b.shares.count
    a.duplicate_of b
    assert_equal combined, b.shares.count
  end
  
  test "should combine has_many :through relation" do
    a = media_artists(:bob_marley)
    b = media_artists(:eminem)
    combined = a.listens.count + b.listens.count
    a.duplicate_of b
    assert_equal combined, b.listens.count
  end
  
  test "should combine habtm relation" do
    song_a = media_songs(:one_love)
    song_b = media_songs(:not_afraid)
    genre = media_genres(:rap)
    song_a.genres << genre unless song_a.genres.include? genre
    song_b.genres << genre unless song_b.genres.include? genre
    song_a.duplicate_of song_b
    
    checked = []
    (song_a.genres + song_b.genres).each do |genre|
      next if genre.in? checked
      assert_includes song_b.genres, genre, "Genre #{genre} not included in song #{song_b}"
      checked << genre
    end
    song_b.genres.each do |genre|
      assert_includes checked, genre, "Genre #{genre} should not be included in song #{song_b}"
    end
    assert_equal checked.size, song_b.genres.count, "There are duplicates"
  end
  
  test "should fail to duplicate different models" do
    assert_raise(TypeError) do
      Media::Song.first.duplicate_of Media::Artist.first
    end
  end
  
  test "should fail to combine non-existing association" do
    assert_raise(ArgumentError) do
      Media::Song.include_associations_of_dups :listens, :this_relation_doesnt_exist, :shares
    end
  end
end