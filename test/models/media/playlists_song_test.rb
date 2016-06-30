# frozen_string_literal: true
require 'test_helper'

class PlaylistsSongTest < ActiveSupport::TestCase
  setup do
    @track = Media::PlaylistsSong.new
    @track.playlist = Media::Playlist.first
    @track.song = Media::Song.first
    @track.position = 42
  end

  test 'should create' do
    assert_difference 'Media::PlaylistsSong.count', +1 do
      @track.save
    end
  end

  test 'should not create without playlist' do
    @track.playlist = nil
    assert_no_difference 'Media::PlaylistsSong.count' do
      @track.save
    end
  end

  test 'should not create without song' do
    @track.song = nil
    assert_no_difference 'Media::PlaylistsSong.count' do
      @track.save
    end
  end
end
