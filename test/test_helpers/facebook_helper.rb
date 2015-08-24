# Copyright (c) 2015 Simplare
require 'test_helpers/backend_helper'

# Helper methods for the tests of the Facebook backend.
module Backends::FacebookTestHelpers
  
  include Backends::TestHelpers
  
  # The path of the file containing the fixtures.
  #
  # The file must be a `YAML` file.
  #
  # FIXME: cannot end in `.yml` since that makes the test engine try to load it
  # into the db.
  FIXTURE_FILE = "test/fixtures/backends/facebook.yaml"
  
  # The Facebook fixtures.
  #
  # Keeps a cache to prevent extension IO. But any embedded ruby code is run at
  # every access.
  def facebook(key)
    unless @raw_youtube_fixtures
      @raw_youtube_fixtures = File.read(FIXTURE_FILE)
    end
    YAML.load(ERB.new(@raw_youtube_fixtures).result)[key]
  end
  
  # Stub a request to CRUD listens.
  #
  # `listens` is either:
  #
  #   - An integer, specifying the number of listens to return.
  #   - A hash describing the single listen to return.
  #   - An array of hashes, describing the listens to return.
  #
  # A random value is used unless a value is specified.
  def stub_listens(listens, options = {})
    options[:url] ||= '/me/music.listens'
    options[:method] ||= :get
    
    listens = (1..listens).map {{}} if listens.is_a? Integer
    listens = [listens] unless listens.is_a? Array
    
    listens.map! do |listen|
      facebook('listen').deep_merge listen.deep_stringify_keys
    end
    
    stub_oauth options[:url], { 'data' => listens }, options
  end
  alias_method :stub_listen, :stub_listens
  
  # Stub a request to CRUD playlists.
  #
  # `playlists` is either:
  #
  #   - An integer, specifying the number of playlists to return.
  #   - A hash describing the single playlist to return.
  #   - An array of hashes, describing the playlists to return.
  #
  # A random value is used unless a value is specified.
  def stub_playlists(playlists, options = {})
    options[:url] ||= '/me/music.playlists'
    options[:method] ||= :get
    
    playlists = (1..playlists).map {{}} if playlists.is_a? Integer
    playlists = [playlists] unless playlists.is_a? Array
    
    playlists.map! do |playlist|
      facebook('playlist').deep_merge playlist.deep_stringify_keys
    end
    
    stub_oauth options[:url], { 'data' => playlists }, options
  end
  alias_method :stub_playlist, :stub_playlists
  
end