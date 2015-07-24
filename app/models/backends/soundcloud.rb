# Copyright (c) 2015 Simplare

module Backends
  
  # The SoundCloud backend which allows for searching for and streaming of songs.
  class Soundcloud < Backends::Base
    
    # Display name for the backend.
    def self.to_s
      "SoundCloud"
    end
  
    # Search SoundCloud for resources.
    #
    # - `query`   
    #   The query to match resources on.
    #
    # - `categories`   
    #   The type of resources to search for.
    def self.search(query, categories)
      songs = []
      return songs unless categories.include? 'songs'
      begin
        tracks = req("tracks.json?q=#{query}")
        tracks.each do |track|
          begin
            song = parse_track(track)
            songs << song if song
          rescue StandardError => e
            Rails.logger.error "error parsing track: #{e.message}"
            raise e
          end
        end
      rescue StandardError => e
        Rails.logger.error "error searching soundcloud: #{e.message}"
        raise e
      end
      return songs
    end
    
    # Generate a resource from the backend.
    def generate_resource
      case resource_type
      when 'Media::Song' then
        self.class.get_songs([resource_id])[0]
      else
        raise "The #{self} backend does not support resources of type #{resource_type}"
      end
    end
  
    # Get an array of songs with IDs `ids`.
    def self.get_songs(ids)
      songs = []
      ids.each do |id|
        begin
          track = req("tracks/#{id}.json")
          songs << parse_track(track)
        rescue StandardError => e
          Rails.logger.error "error parsing soundcloud json track: #{e.message}"
        end
      end
      return songs
    end
  
    private
  
    def self.parse_track(track)
      artists, title = Media::Song.parse_title(track['title'])
      artists = [track['user']['username']] if artists.blank?
      song = {
        type: :song,
        title: title,
        images: [],
        genre: track['genre'],
        artists: artists.map { |n| { name: n } },
        #stream: track['stream_url'],
        source: {
          foreign_url: track['permalink_url'],
          foreign_id: track['id'],
          popularity: track['playback_count'].to_f,
          length: track['duration'].to_f / 1000.0
        }
      }
      if track['artwork_url']
        song[:images] << { url: track['artwork_url'] }
      end
      return song
    end
  
    def self.req(query)
      begin
        query = URI.escape(query)
        url = "#{creds['url']}/#{query}"
        url = URI.parse(url)
        url.query = [url.query, "client_id=#{creds['id']}"].compact.join('&')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == 'https')
        Rails.logger.debug "fetching: #{url}"
        data = http.get(url.request_uri)
        feed = JSON.parse(data.body)
        return feed
      rescue StandardError => e
        raise e
        Rails.logger.error "error making request: #{e.message}"
      end
      
      http = Net::HTTP.new("api.soundcloud.com", 443)
      http.use_ssl = true
      data = http.get("/tracks/#{song.soundcloud_id}.json?client_id=#{client_id}", {})
      track = JSON.parse(data.body)
    end
  
    # The API credentials
    def self.creds
      Rails.application.secrets.oa_cred['soundcloud']
    end
    
  end # class
  
end # module