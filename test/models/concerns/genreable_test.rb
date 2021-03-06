# frozen_string_literal: true
require 'test_helper'

class GenreableTest < ActiveSupport::TestCase
  def setup
    @song = media_songs(:one_love)
    super
  end

  test 'should set genres' do
    reggae = media_genres(:reggae)
    assert_difference 'Media::Genre.count', 1, "Didn't create new genre" do
      @song.genre = "#{reggae}, Roots reggae"
    end
    roots_reggae = Media::Genre.find_by(name: 'Roots reggae')
    assert roots_reggae, "Didn't create proper genre"
    assert_equal 2, @song.genres.count, "Didn't split artists string into two"
    assert_includes @song.genres, reggae, "#{reggae} was not in collection"
    assert_includes @song.genres, roots_reggae,
                    "#{roots_reggae} was not in collection"
  end

  test 'should get genres' do
    assert_equal 'Reggae and Ska', @song.genre
  end

  test 'should not create new genre' do
    assert_no_difference 'Media::Genre.count', 'Created new genre' do
      @song.genre = 'SKA,REGGAE'
    end
  end
end
