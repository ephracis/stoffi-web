require 'test_helper'

class SourceableTest < ActiveSupport::TestCase
  
  test 'should create resource' do
    assert_difference "Media::Song.count", 1, "Didn't create song" do
      s = Media::Song.create_by_hash({ title: 'Test Song' })
      assert s, "Didn't return song"
    end
  end
  
  test 'should create belongs_to association' do
    # TODO: we have no such models to test
  end
  
  test 'should create has_many association' do
    # TODO: we have no such models to test
  end
  
  test 'should not create has_many :through association' do
    hash = {
      name: 'Test Event',
      venue: 'Some place',
      start: DateTime.now,
      longitude: 1.23,
      latitude: 3.21,
      songs: [ # through 'Eminem'
        { title: 'Not Afraid' }
      ]
    }
    assert_difference "Media::Event.count", 1, "Didn't create event" do
    assert_no_difference "Media::Song.count", "Created a song" do
      x = Media::Event.create_by_hash(hash)
      assert x, "Didn't return event"
    end
    end
  end
  
  test 'should create has_and_belongs_to_many association' do
    hash = {
      title: 'Test Song',
      artists: [
        { name: 'Eminem' },
        { name: 'Dido' }
      ]
    }
    assert_difference "Media::Song.count", 1, "Didn't create song" do
      # since 'Eminem' already exists, only 'Dido' should be created
      assert_difference "Media::Artist.count", 1, "Didn't create single artist" do
        s = Media::Song.create_by_hash(hash)
        assert s, "Didn't return song"
        assert_equal 2, s.artists.length, "Didn't assign two artists"
        assert_includes s.artists.map(&:to_s), 'Eminem', "Didn't assign artist Eminem"
        assert_includes s.artists.map(&:to_s), 'Dido', "Didn't assign artist Dido"
      end
    end
  end
  
  test 'should create associations recursively' do
    hash = {
      name: 'Test Event',
      venue: 'Some place',
      start: DateTime.now,
      longitude: 1.23,
      latitude: 3.21,
      artists: [
        {
          name: 'Eminem',   
          songs: [
            { title: 'Not Afraid' },
            { title: 'Stan' }
          ]
        } # eminem
      ] # artists
    }
    
    # since 'Not Afraid' already exists, only 'Stan' should be created
    assert_difference "Media::Event.count", 1, "Didn't create event" do
      assert_no_difference "Media::Artist.count", "Created artist although it already exists" do
      assert_difference "media_artists(:eminem).songs.count", 1, "Didn't assign 'Stan' to Eminem" do
        assert_difference "Media::Song.count", 1, "Didn't create 'Stan', and 'Stan' only" do
          e = Media::Event.create_by_hash(hash)
          assert e, "Didn't return event"
          assert_equal 1, e.artists.length, "Didn't assign one artist"
          assert_equal 'Eminem', e.artists[0].name, "Didn't assign artist Eminem"
          assert_includes e.artists[0].songs.map(&:to_s), 'Not Afraid', "Didn't assign song Not Afraid"
          assert_includes e.artists[0].songs.map(&:to_s), 'Stan', "Didn't assign song Stan"
        end # songs
      end # eminem
      end # artists
    end # event
    
  end
  
  test 'should extract associations' do
    hash = { name: 'foo', venue: 'bar', non_attribute: 'baz', artists: [{ name: 'My Artist'}] }
    assoc = Media::Song.send('extract_associations!', hash)
    
    assert_includes assoc.keys, :artists
    assert_not_includes assoc.keys, :venue
    assert_not_includes assoc.keys, :name
    
    assert_not_includes hash.keys, :artists
    assert_includes hash.keys, :venue
    assert_includes hash.keys, :name
  end
  
  test 'should remove non-attributes' do
    hash = { name: 'foo', venue: 'bar', non_attribute: 'baz' }
    Media::Event.send('remove_non_attributes!', hash)
    assert_not hash.key?(:non_attribute), "Didn't remove key from hash"
  end
  
end