# frozen_string_literal: true
require 'test_helper'

class ListenTest < ActiveSupport::TestCase
  setup do
    @listen = Media::Listen.new
    @listen.song = media_songs(:not_afraid)
    @listen.user = users(:alice)
    @listen.device = accounts_devices(:alice_pc)
    @listen.playlist = media_playlists(:foo)
    @listen.created_at = Time.current
  end

  test 'should create listen' do
    assert_difference 'Media::Listen.count', 1, "Didn't create listen" do
      @listen.save
    end
  end

  test "shouldn't create listen without song" do
    @listen.song = nil
    assert_no_difference 'Media::Listen.count', 'Saved without song' do
      @listen.save
    end
  end

  test "shouldn't create listen without user" do
    @listen.user = nil
    assert_no_difference 'Media::Listen.count', 'Saved without user' do
      @listen.save
    end
  end

  test "shouldn't create listen without device" do
    @listen.device = nil
    assert_no_difference 'Media::Listen.count', 'Saved without device' do
      @listen.save
    end
  end

  test 'should get duration' do
    duration = 5.seconds
    @listen.ended_at = @listen.created_at + duration
    assert_equal duration, @listen.duration
  end
end
