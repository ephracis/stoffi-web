# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Backends
  # The YouTube backend.
  #
  # Allows for searching for songs (videos) and stream them via a view.
  class Youtube < Backends::Base
    SEARCH_PARTS = 'id'
    SEARCH_FIELDS = 'items(id/videoId)'
    DETAILS_PARTS = 'id,snippet,statistics,contentDetails'
    DETAILS_FIELDS = 'items(id,snippet(title,thumbnails),'\
                     'statistics/viewCount,contentDetails/duration)'

    def self.to_s
      'YouTube'
    end

    # Search for a query in a given set of categories
    def self.search(query, categories)
      return [] unless categories.include? 'songs'

      path  = 'search?type=video&maxResults=20&videoCategoryId=10'
      path += '&videoEmbeddable=true'
      path += "&part=#{SEARCH_PARTS}&fields=#{SEARCH_FIELDS}"
      path += "&q=#{query}"
      response = req(path)
      ids = response['items'].collect { |i| i['id']['videoId'] }

      return get_songs(ids)
    rescue
      []
    end

    # Get an array of songs with IDs `ids`.
    def self.get_songs(ids)
      songs = []

      begin
        ids = ids.join(',')
        path = "videos?part=#{DETAILS_PARTS}&fields=#{DETAILS_FIELDS}&id=#{ids}"
        response = req(path)
        response['items'].each do |i|
          begin
            begin
              dur = Duration.new(i['contentDetails']['duration']).total.to_f
            rescue
              dur = 0.0
            end
            artists, title = Media::Song.parse_title(i['snippet']['title'])
            song = {
              type: :song,
              title: title,
              artists: artists.map { |n| { name: n } },
              images: i['snippet']['thumbnails'].values,
              source: {
                foreign_id: i['id'],
                foreign_url: "https://www.youtube.com/watch?v=#{i['id']}",
                popularity: i['statistics']['viewCount'].to_f,
                length: dur
              }
            }
            songs << song
          rescue StandardError => e
            raise e if Rails.env.test?
            logger.error "error parsing youtube json video: #{e.message}"
          end
        end

      rescue StandardError => e
        raise e if Rails.env.test?
        Rails.logger.error "error retrieving youtube videos: #{e.message}"
      end

      songs
    end

    # Generate a resource from the backend.
    def generate_resource
      case resource_type.demodulize
      when 'Song' then
        self.class.get_songs([resource_id])[0]
      else
        raise "The #{self} backend does not support resources of "\
              "type #{resource_type}"
      end
    end

    private_class_method

    # Make a request to the API
    # TODO: move to base
    def self.req(query)
      query = URI.escape(query)
      url = "#{creds['url']}/#{query}"
      url = URI.parse(url)
      url.query = [url.query, "key=#{creds['key']}"].compact.join('&')
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      Rails.logger.debug "fetching: #{url}"
      data = http.get(url.request_uri)
      feed = JSON.parse(data.body)
      return feed
    rescue StandardError => e
      Rails.logger.error "error making request: #{e.message}"
      raise e if Rails.env.test?
    end
  end # class
end # module
