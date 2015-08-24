require 'test_helper'

class Media::EventTest < ActiveSupport::TestCase
  
  test "should create event" do
    e = nil
    hash = {
      name: 'Foo',
      category: 'festival',
      artists: [ {name:'Eminem'}, {name:'Bob Marley'}],
      longitude: 15,
      latitude: 15,
      venue: 'Something',
      start: 2.days.from_now,
      source: {
        name: :lastfm,
        foreign_id: '123',
        popularity: '123',
        foreign_url: 'http://foo.org/',
      },
      images: [
        { url: 'http://foo.com/img1.jpg' },
        { url: 'http://foo.com/img2.jpg' },
      ],
    }
    assert_difference 'Media::Event.count', 1, "Didn't create new event" do
      e = Media::Event.find_or_create_by_hash(hash)
    end
    assert e, "Didn't return event"
    assert_equal hash[:name], e.name, "Didn't set name"
    assert_equal hash[:venue], e.venue, "Didn't set venue"
    assert_equal hash[:start].to_s, e.start.to_s, "Didn't set start date"
    assert_equal hash[:longitude], e.longitude, "Didn't set location"
    
    assert_equal hash[:artists].length, e.artists.count, "Didn't set artists"
    assert_equal hash[:images].length, e.images.count, "Didn't set images"
    assert_equal 1, e.sources.count, "Didn't set source"
    
    s = e.sources[0]
    
    assert_equal hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal hash[:source][:name].to_s, s.name, "Didn't set source name"
  end
  
  test "should find event" do
    e = media_events(:concert2)
    hash = {
      name: e.name,
      longitude: e.longitude,
      latitude: e.latitude,
      venue: e.venue,
      start: e.start,
      stop: e.stop,
      source: {
        name: :lastfm,
        popularity: '123',
        foreign_id: '123',
        foreign_url: 'http://foo.org/',
      },
      images: [
        { url: 'http://foo.com/img1.jpg' },
        { url: 'http://foo.com/img2.jpg' },
      ],
    }
    event = nil
    assert_no_difference 'Media::Event.count', "Created new event" do
      event = Media::Event.find_or_create_by_hash(hash)
    end
    assert_equal e, event, "Didn't return correct event"
    
    s = e.sources.where(name: :lastfm).first
    assert s, "Didn't set source"
    assert_equal hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal hash[:source][:name].to_s, s.name, "Didn't set source name"
  end
  
  test "should get top events" do
    e = Media::Event.top limit: 3
    assert_equal 3, e.length, "Didn't return three top events"
    assert e[0].listens.count == e[1].listens.count, "Top events not in order (first and second, listens)"
    assert e[0].popularity    >= e[1].popularity, "Top events not in order (first and second, popularity)"
    assert e[1].listens.count >= e[2].listens.count, "Top events not in order (second and third)"
  end
end
