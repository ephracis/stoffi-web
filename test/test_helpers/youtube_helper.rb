# frozen_string_literal: true
# Copyright (c) 2016 Simplare
require 'test_helpers/backend_helper'

# Helper methods for the tests of the YouTube backend.
module Backends
  module YoutubeTestHelpers
    include Backends::TestHelpers

    # The path of the file containing the fixtures.
    #
    # The file must be a `YAML` file.
    #
    # FIXME: cannot end in `.yml` since that makes the test engine try to load
    # it into the db.
    FIXTURE_FILE = 'test/fixtures/backends/youtube.yaml'

    # The YouTube fixtures.
    #
    # Keeps a cache to prevent extension IO. But any embedded ruby code is run
    # at every access.
    def youtube(key)
      unless @raw_youtube_fixtures
        @raw_youtube_fixtures = File.read(FIXTURE_FILE)
      end
      YAML.load(ERB.new(@raw_youtube_fixtures).result)[key]
    end

    # Stub a request to get detailed info on specific videos.
    #
    # `videos` is either:
    #
    #   - An integer, specifying the number of videos to return.
    #   - A hash describing the single video to return.
    #   - An array of hashes, describing the videos to return.
    #
    # A random value is used unless the value is specified.
    def stub_youtube_videos(videos)
      videos = (1..videos).map { {} } if videos.is_a? Integer
      videos = [videos] unless videos.is_a? Array

      videos.map! do |video|
        youtube('video').deep_merge video.stringify_keys
      end

      stub_request(:any, %r{https://www.googleapis.com/youtube/v3/videos.*})
        .to_return(body: { 'items' => videos }.to_json, status: 200)
    end
    alias stub_youtube_video stub_youtube_videos

    # Stub a request for searching for videos..
    #
    # `results` can either be an integer specifying the number of videos, with
    # a random id, to return, or an array of the ids to return.
    def stub_youtube_search(results)
      results = (1..results).map { {} } if results.is_a? Integer
      results = [results] unless results.is_a? Array

      results.map! do |result|
        youtube('search_result').deep_merge result.stringify_keys
      end
      stub_request(:any, %r{https://www.googleapis.com/youtube/v3/search.*})
        .to_return(body: { 'items' => results }.to_json, status: 200)
    end
  end
end
