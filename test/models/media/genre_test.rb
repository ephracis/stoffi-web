require 'test_helper'

class Media::GenreTest < ActiveSupport::TestCase
  setup do
    @hash = {
      name: 'Foo',
      source: {
        name: :lastfm,
        foreign_url: 'http://foo.com/genre1',
        popularity: '123',
        foreign_id: 'foo',
      },
      images: [
        { url: 'http://foo.com/img1.jpg' },
        { url: 'http://foo.com/img2.jpg' },
      ],
    }
  end
  
  test "should get top genres" do
    g = Media::Genre.rank.limit 3
    assert_equal 3, g.length, "Didn't return three top genres"
    assert g[0].listens.count >= g[1].listens.count, "Top genres not in order (first and second)"
    assert g[1].listens.count >= g[2].listens.count, "Top genres not in order (second and third)"
  end
  
  test "should create genre" do
    g = nil
    assert_difference 'Media::Genre.count', 1, "Didn't create new genre" do
      g = Media::Genre.find_or_create_by_hash(@hash)
    end
    assert g, "Didn't return genre"
    assert_equal @hash[:name], g.name, "Didn't set name"
    
    assert g.images.where(url: @hash[:images][0][:url]).any?, "Didn't set images"
    
    s = g.sources[0]
    assert s, "Didn't set source"
    assert_equal @hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal @hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal @hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal @hash[:source][:name].to_s, s.name, "Didn't set source name"
  end
  
  test "should find genre" do
    ska = media_genres(:ska)
    g = nil
    @hash[:name] = ska.name
    assert_no_difference 'Media::Genre.count', "Created new genre" do
      g = Media::Genre.find_or_create_by_hash(@hash)
    end
    assert_equal ska, g, "Didn't return correct genre"
    
    assert g.images.where(url: @hash[:images][0][:url]).any?, "Didn't set images"
    
    s = g.sources.where(name: :lastfm).first
    assert s, "Didn't set source"
    assert_equal @hash[:source][:popularity].to_f, s.popularity, "Didn't set source popularity"
    assert_equal @hash[:source][:foreign_id], s.foreign_id, "Didn't set source id"
    assert_equal @hash[:source][:foreign_url], s.foreign_url, "Didn't set source url"
    assert_equal @hash[:source][:name].to_s, s.name, "Didn't set source name"
  end
end
