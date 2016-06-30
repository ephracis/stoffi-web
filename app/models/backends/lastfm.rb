# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Backends
  # The Last.fm backend.
  #
  # Supports searching for resources such as songs, artists, albums and events.
  #
  # It also supports sending shares and listens for authenticated users, and
  # retrieving their data such as profile picture and username.
  class Lastfm < Backends::Base
    # Generate a resource from the backend.
    def generate_resource
      case resource_type
      when 'Song' then
        self.class.get_info resource_id, 'track'
      when 'Artist', 'Album', 'Event' then
        self.class.get_info resource_id, resource_type.downcase
      else
        raise "The #{self} backend does not support resources of "\
              "type #{resource_type}"
      end
    end

    # Whether or not the backend supports showing a "Like" button.
    def button?
      false
    end

    # Whether or not playlists can be submitted to and retrieved from Facebook.
    def playlists?
      false
    end

    # Whether or not listens can be submitted to Facebook.
    def listens?
      false
    end

    # Whether or not shares can be submitted to Facebook.
    def shares?
      true
    end

    # The authenticated user's profile pictures.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def picture
    end

    # The authenticated user's name.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def name
    end

    # An array of the authenticated user's friends.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def friends
    end

    # Share a resource as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def share(resource)
    end

    # Update the *Now playing* status of the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def start_listen(listen)
      params =
        {
          artist: listen.song.artist_names,
          track: listen.song.title,
          duration: listen.song.length.to_i,
          timestamp: listen.created_at.to_i
        }
      params[:album] = listen.album.name if listen.album

      resp = req('track.updateNowPlaying', :post, params)
      raise resp['message'] if resp['error']
    end

    # Scrobble a song for the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def end_listen(listen)
      params =
        {
          artist: listen.song.artist_names,
          track: listen.song.title,
          duration: listen.song.length.to_i,
          timestamp: listen.created_at.to_i
        }
      params[:album] = listen.album.name if listen.album

      resp = req('track.scrobble', :post, params)
      raise resp['message'] if resp['error']
    end

    # The display name of the backend.
    def self.to_s
      'Last.fm'
    end

    # Search for a query in a given set of categories
    def self.search(query, categories)
      hits = { 'artists' => [], 'albums' => [], 'songs' => [], 'events' => [] }
      threads = []

      hits.each do |k, v|
        next unless categories.include? k
        threads << Thread.new do
          v.concat search_for(category_to_resource(k), query)
        end
      end
      threads.each(&:join)

      hits.inject([]) { |a, (_k, v)| a.concat v }
    end

    # Get detailed info on a resource.
    #
    # `name` is the unique identifier of the resource, either its name,
    # or its artist followed by a tab, followed by its name.
    #
    # `category` is the type of the resource.
    def self.get_info(name, category)
      resource = category_to_resource(category)
      hit = nil
      case resource
      when 'artist', 'event'
        hit = get_resource_info(resource, "#{resource}=#{name}")
      else
        parts = name.split("\t")
        raise 'Need to specify artist' if parts.length < 2
        name = parts[0]
        artist = parts[1]
        query = "artist=#{artist}&#{resource}=#{name}"
        hit = get_resource_info(resource, query)
      end
      parse_hit(hit, resource)
    end

    private_class_method

    # TODO: use OAuth::AccessToken instead
    def req(method, verb, params = {})
      params[:api_key] = self.class.creds['id']
      params[:method] = method
      params[:sk] = access_token

      params[:format] = 'json' if verb == :get

      params[:api_sig] = Digest::MD5.hexdigest(
        params.stringify_keys.sort.flatten.join + self.class.creds['key']
      )

      params[:format] = 'json' if verb == :post

      response = case verb
                 when :get
                   uri = URI.parse(self.class.creds['url'] + '/2.0/?' +
                    params.to_query)
                   Net::HTTP.get(uri)

                 when :post
                   uri = URI.parse(self.class.creds['url'] + '/2.0/')
                   Net::HTTP.post_form(uri, params).body

                 else
                   raise 'Unsupported HTTP Verb'
                 end

      JSON.parse(response)
    end

    # Turn a category into a resource
    def self.category_to_resource(category)
      category = category.singularize
      return 'track' if category == 'song'
      category
    end

    # Turn a resource into a type
    def self.resource_to_type(resource)
      case resource
      when 'track' then :song
      else resource.to_sym
      end
    end

    # Search for a given resource
    def self.search_for(resource, query)
      hits = []
      begin
        get_hits(resource, query) do |h|
          begin
            hit = parse_hit(h, resource)
            hits << hit if hit

          rescue StandardError => e
            Rails.logger.error "error parsing hit #{h.inspect}: #{e.message}"
          end
        end
      rescue StandardError => e
        Rails.logger.error "error searching for resource #{resource}: " +
                           e.message
      end
      hits
    end

    # Parse a given resource from a response and return it as a hash.
    #
    # The returned hash follows a format which can be used in
    # `find_or_create_by_hash` as defined in `Sourceable`.
    def self.parse_hit(hit, resource)
      return nil unless hit
      retval = {
        images: [],
        source: { foreign_url: hit['url'] }
      }
      return nil unless resource.in? %w(artist album track event)
      send("parse_#{resource}_hit", retval, hit)

      if hit['image']
        hit['image'].each do |i|
          retval[:images] << { url: i['#text'] }
        end
      end

      retval
    end

    # Parse an artist resource from a response and return it as a hash.
    #
    # The returned hash follows a format which can be used in
    # `find_or_create_by_hash` as defined in `Sourceable`.
    def self.parse_artist_hit(hash, hit)
      hash[:type] = :artist
      hash[:name] = hit['name']
      hash[:source][:popularity] = hit['listeners'].to_f
      hash[:source][:foreign_id] = hit['name']
    end

    # Parse an album resource from a response and return it as a hash.
    #
    # The returned hash follows a format which can be used in
    # `find_or_create_by_hash` as defined in `Sourceable`.
    def self.parse_album_hit(hash, hit)
      hash[:type] = :album
      hash[:title] = hit['name']
      hash[:artists] = [{ name: hit['artist'] }]
      hash[:fullname] = "#{hit['name']} by #{hit['artist']}"
      hash[:source][:foreign_id] = "#{hit['name']}\t#{hit['artist']}"
    end

    # Parse a track resource from a response and return it as a hash.
    #
    # The returned hash follows a format which can be used in
    # `find_or_create_by_hash` as defined in `Sourceable`.
    def self.parse_track_hit(hash, hit)
      hash[:type] = :song
      hash[:title] = hit['name']
      hash[:artists] = [{ name: hit['artist'] }]
      hash[:source][:popularity] = hit['listeners'].to_f
      hash[:source][:foreign_id] = "#{hit['name']}\t#{hit['artist']}"
    end

    # Parse an event resource from a response and return it as a hash.
    #
    # The returned hash follows a format which can be used in
    # `find_or_create_by_hash` as defined in `Sourceable`.
    def self.parse_event_hit(hash, hit)
      hash[:type] = :event
      hash[:name] = hit['title']
      hash[:longitude] = hit['venue']['location']['geo:point']['geo:long'].to_f
      hash[:latitude] = hit['venue']['location']['geo:point']['geo:lat'].to_f
      hash[:venue] = hit['venue']['location']['city']
      hash[:start] = hit['startDate']
      hash[:end] = hit['endDate']

      hash[:source][:popularity] = hit['attendance'].to_f
      hash[:source][:id] = hit['id']

      a = hit['artists']['artist']
      a = [a] unless a.is_a? Array
      hash[:artists] = a.map { |n| { name: n } }
    end

    # Extract the array of hits from a search response
    def self.get_resource_info(resource, query)
      response = req("method=#{resource}.getInfo&#{query}")
      return response[resource] if response[resource]
    rescue StandardError => e
      Rails.logger.debug response.inspect
      Rails.logger.error "Error getting hits for resource #{resource}: " +
                         e.message
    end

    # Extract the array of hits from a search response
    def self.get_hits(resource, query)
      response = req("method=#{resource}.search&#{resource}=#{query}")
      return if response['results']['opensearch:totalResults'] == '0'
      hits = response['results']["#{resource}matches"][resource]
      hits.each { |h| yield h }
    rescue StandardError => e
      Rails.logger.debug response.inspect
      Rails.logger.error "Error getting hits for resource #{resource}: " +
                         e.message
    end

    # Make a request to the API
    def self.req(query)
      query = URI.escape(query)
      url = "#{creds['url']}/2.0?#{query}&format=json&api_key=#{creds['id']}"
      url = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      Rails.logger.debug "fetching: #{url}"
      data = http.get(url.request_uri)
      feed = JSON.parse(data.body)
      return feed
    rescue StandardError => e
      Rails.logger.error "error making request: #{e.message}"
    end

    # The API credentials
    def self.creds
      Rails.application.secrets.oa_cred['lastfm']
    end
  end # class
end # module
