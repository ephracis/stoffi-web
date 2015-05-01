require 'test_helper'

class SourceTest < ActiveSupport::TestCase
	test "should validate name uniqueness" do
		a = Artist.new
		a.name = Artist.first.name
    	assert !a.save, "Created artist with non-unique name"
	end
	
	test "should get new artist" do
		a = nil
		name = 'Stephen Marley'
		assert_difference "Artist.count", 1, "Didn't create new artist" do
			a = Artist.get(name)
		end
		assert_equal name, a.name, "Didn't set correct name"
	end
	
	test "should get existing artist" do
		a = nil
		artist = artists(:eminem)
		assert_no_difference "Artist.count", "Created new artist" do
			a = Artist.get(artist.name)
		end
		assert_equal artist, a, "Didn't get correct artist"
	end
	
	test "should get by hash" do
		a = nil
		hash = {
			name: 'Stephen Marley',
			popularity: 123,
			images: [
				{ url: 'http://foo.com/img1.jpg', width: 32, height: 32 },
				{ url: 'http://foo.com/img2.jpg', width: 64, height: 64 },
				{ url: 'http://foo.com/img3.jpg', width: 128, height: 128 },
			],
			type: :artist,
			source: :lastfm,
			id: 42,
			url: 'http://foo.com/artist'
		}
		assert_difference "Artist.count", 1, "Didn't create new artist" do
			a = Artist.get(hash)
		end
		assert a, "Didn't return artist"
		assert_equal hash[:name], a.name, "Didn't set correct name"
		assert_equal hash[:images][1][:url], a.images.get_size(:small).url, "Didn't set images"
		assert_equal 1, a.sources.count, "Didn't set source"
		assert_equal hash[:popularity], a.sources[0].popularity, "Didn't set popularity"
		assert_equal hash[:source], a.sources[0].name, "Didn't set source name"
	end
	
	test "should split name" do
		a = Artist.split_name("Foo & 	Bar")
		assert_equal ["Foo", "Bar"], a
		a = Artist.split_name("Foo+ Bar")
		assert_equal ["Foo", "Bar"], a
		a = Artist.split_name("Foo, Bar")
		assert_equal ["Foo", "Bar"], a
		a = Artist.split_name("Foo & Bar feat.Baz")
		assert_equal ["Foo", "Bar", "Baz"], a
		a = Artist.split_name("Foo")
		assert_equal ["Foo"], a
		a = Artist.split_name("")
		assert_equal [], a
	end
	
	test "should get top artists" do
		a = Artist.top.limit 3
		assert_equal 3, a.length, "Didn't get three artists"
		assert a[0].listens.count >= a[1].listens.count, "Top artists not in order (first and second)"
		assert a[1].listens.count >= a[2].listens.count, "Top artists not in order (second and third)"
	end
end
