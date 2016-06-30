# frozen_string_literal: true
# Copyright (c) 2015 Simplare
require 'test_helpers/backend_helper'

# Helper methods for the tests of the Last.fm backend.
module Backends
  module LastfmTestHelpers
    include Backends::TestHelpers

    # The path of the file containing the fixtures.
    #
    # The file must be a `YAML` file.
    #
    # FIXME: cannot end in `.yml` since that makes the test engine try to load
    # it into the db.
    FIXTURE_FILE = 'test/fixtures/backends/lastfm.yaml'

    # The Last.fm fixtures.
    #
    # Keeps a cache to prevent extension IO. But any embedded ruby code is run
    # at every access.
    def lastfm(key)
      @raw_lastfm_fixtures = File.read(FIXTURE_FILE) unless @raw_lastfm_fixtures
      YAML.load(ERB.new(@raw_lastfm_fixtures).result)[key]
    end

    %w(artist album track event).each do |klass|
      define_method "stub_lastfm_#{klass}_search" do |resources|
        stub_lastfm_search klass, resources
      end
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
    def stub_lastfm_search(klass, resources)
      resources = (1..resources).map { {} } if resources.is_a? Integer
      resources = [resources] unless resources.is_a? Array

      resources.map! { |r| lastfm(klass).deep_merge r.stringify_keys }

      response = { 'results' => {
        'opensearch:totalResults' => resources.length.to_s,
        "#{klass}matches" => { klass => resources }
      } }

      stub_request(:any, /.*ws.audioscrobbler.com.*method=#{klass}\.search.*/)
        .to_return(body: response.to_json, status: 200)
    end

    # Stub a request for detailed info on a resource on Last.fm.
    #
    # `klass` is the name of the resource type.
    #
    # `resource` is a hash describing the resource to return. A random value is
    # used unless the value is specified.
    def stub_lastfm_info(klass, resource = {})
      resource = lastfm(klass).deep_merge resource.stringify_keys
      response = { klass => resource }
      domain = 'ws.audioscrobbler.com'
      url = case klass
            when 'track' then
              /.*#{domain}.*artist=.*method=#{klass}\.getInfo.*#{klass}=.*/
            else
              /.*#{domain}.*#{klass}=.*method=#{klass}\.getInfo.*/
            end

      stub_request(:any, url).to_return(body: response.to_json, status: 200)
    end

    # Stub a request for detailed info on a non-existing resource on Last.fm.
    def stub_lastfm_invalid(klass, _resource = {})
      response = { 'error' => 6, 'message' => "#{klass.capitalize} not found",
                   'links' => [] }
      domain = 'ws.audioscrobbler.com'
      url = case klass
            when 'track' then
              /.*#{domain}.*artist=.*method=#{klass}\.getInfo.*#{klass}=.*/
            else
              /.*#{domain}.*#{klass}=.*method=#{klass}\.getInfo.*/
            end
      stub_request(:any, url)
        .to_return(body: response.to_json, status: 200)
    end
  end
end
