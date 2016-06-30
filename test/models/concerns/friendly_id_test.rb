# frozen_string_literal: true
require 'test_helper'

class ConcernFriendlyIdTest < ActiveSupport::TestCase
  test 'should display pretty params for users' do
    x = User.first
    x.slug = nil
    x.name = 'Foo Bar'
    x.save!
    assert 'foo-bar'.in?(x.to_param), "#{x.to_param} doesn't contain slug"
  end

  test 'should display pretty params for playlists' do
    x = Media::Playlist.first
    x.name = 'Foo Bar'
    x.save!
    assert 'foo-bar'.in?(x.to_param), "#{x.to_param} doesn't contain slug"
  end
end
