# Copyright (c) 2015 Simplare
require 'test_helpers/backend_helper'

# Helper methods for the tests of the SoundCloud backend.
module Backends::SoundcloudTestHelpers
  
  include Backends::TestHelpers
  
  # The path of the file containing the fixtures.
  #
  # The file must be a `YAML` file.
  #
  # FIXME: cannot end in `.yml` since that makes the test engine try to load it
  # into the db.
  FIXTURE_FILE = "test/fixtures/backends/soundcloud.yaml"
  
  # The SoundCloud fixtures.
  #
  # Keeps a cache to prevent extension IO. But any embedded ruby code is run at
  # every access.
  def soundcloud(key)
    unless @raw_soundcloud_fixtures
      @raw_soundcloud_fixtures = File.read(FIXTURE_FILE)
    end
    YAML.load(ERB.new(@raw_soundcloud_fixtures).result)[key]
  end
  
  # Stub a request to search for a given class of resources.
  #
  # `klass` is the name of the resource type.
  #
  # `resources` is either:
  #
  #   - An integer, specifying the number of resources to return.
  #   - A hash describing the single resource to return.
  #   - An array of hashes, describing the resources to return.
  #
  # A random value is used unless the value is specified.
  def stub_soundcloud_search(klass, resources)
    resources = (1..resources).map {{}} if resources.is_a? Integer
    resources = [resources] unless resources.is_a? Array
    
    resources.map! do |resource|
      soundcloud(klass).deep_merge resource.stringify_keys
    end
    
    stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\.json.*q=.*/).
      to_return(:body => resources.to_json, :status => 200)
  end
  
  # Stub a request for a specific song.
  #
  # `song` is a hash describing the song. A random value is used unless the value is
  # specified.
  def stub_soundcloud_song(song)
    song = soundcloud('song').deep_merge song.stringify_keys
    stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/\w+\.json.*/).
      to_return(:body => song.to_json, :status => 200)
  end
  
end