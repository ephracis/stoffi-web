require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  
  setup do
    @hash = {
      name: 'New Artist',
      images: [
        { url: 'http://foo.com/img1.jpg', width: 32, height: 32 },
        { url: 'http://foo.com/img2.jpg', width: 64, height: 64 },
        { url: 'http://foo.com/img3.jpg', width: 128, height: 128 },
      ],
      source: {
        popularity: 123,
        name: :lastfm,
        foreign_id: 42,
        foreign_url: 'http://foo.com/artist' 
      }
    }
  end
  
  test "should validate name uniqueness" do
    a = Media::Artist.new
    a.name = Media::Artist.first.name
      assert !a.save, "Created artist with non-unique name"
  end
  
  test "should find by hash" do
    a = nil
    artist = media_artists(:eminem)
    @hash[:name] = artist.name
    assert_no_difference "Media::Artist.count", "Created new artist" do
      assert_difference "artist.sources.count", 1, "Didn't assign new source" do
        a = Media::Artist.find_or_create_by_hash @hash
      end
    end
    assert_equal artist, a, "Didn't get correct artist"
  end
  
  test "should create from hash" do
    a = nil
    assert_difference "Media::Artist.count", 1, "Didn't create new artist" do
      a = Media::Artist.find_or_create_by_hash @hash
    end
    assert a, "Didn't return artist"
    assert_equal @hash[:name], a.name, "Didn't set correct name"
    assert_equal @hash[:images].length, a.images.count, "Didn't assign images"
    assert_equal @hash[:images][1][:url], a.images.get_size(:small).url, "Didn't set image url"
    assert_equal 1, a.sources.count, "Didn't set source"
    assert_equal @hash[:source][:popularity], a.sources[0].popularity, "Didn't set popularity"
    assert_equal @hash[:source][:name].to_s, a.sources[0].name, "Didn't set source name"
  end
  
  test "should split name" do
    a = Media::Artist.split_name("Foo &  Bar")
    assert_equal ["Foo", "Bar"].sort, a.sort
    
    a = Media::Artist.split_name("Foo+ Bar")
    assert_equal ["Foo", "Bar"].sort, a.sort
    
    a = Media::Artist.split_name("Foo, Bar")
    assert_equal ["Foo", "Bar"].sort, a.sort
    
    a = Media::Artist.split_name("Foo & Bar, Baz")
    assert_equal ["Foo", "Bar", "Baz"].sort, a.sort
    
    a = Media::Artist.split_name("Foo & Bar feat.Baz")
    assert_equal ["Foo", "Bar", "Baz"].sort, a.sort
    
    a = Media::Artist.split_name("Foo")
    assert_equal ["Foo"], a
    
    a = Media::Artist.split_name("")
    assert_equal [], a
  end
  
  test "should get top artists" do
    a = Media::Artist.rank.limit 3
    assert_equal 2, a.length, "Didn't get three artists"
    assert a[0].listens.count >= a[1].listens.count, "Top artists not in order (first and second)"
  end
end
