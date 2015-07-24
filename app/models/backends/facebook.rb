# Copyright (c) 2015 Simplare

module Backends
  
  # The Facebook backend.
  #
  # Allows for fetching an authenticated user's data such as listens, playlists
  # and profile picture.
  #
  # The backend also supports submitting new listens and share content.
  class Facebook < Backends::Base
    
    include Rails.application.routes.url_helpers
    
    # Whether or not the backend supports showing a "Like" button.
    def can_show_button?; true; end
    
    # Whether or not playlists can be submitted to and retrieved from Facebook.
    def can_send_playlists?; true; end
    
    # Whether or not listens can be submitted to Facebook.
    def can_send_listens?; true; end
    
    # Whether or not shares can be submitted to Facebook.
    def can_send_shares?; true; end
    
    # The authenticated user's profile pictures.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def picture
      response = get("/me/picture?type=large&redirect=false")
      return response['data']['url']
    end
    
    # The authenticated user's fullname and username.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def names
      response = get("/me?fields=name,username")
      r = { fullname: response['name'] }
      r[:username] = response['username'] if response['username'] != nil
      return r
    end
    
    # An array of the authenticated user's friends.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def friends
    end
    
    # Share a resource as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def share(message, options = {})
      post('/me/feed', params:
      {
        message: message,
        link: options[:link],
        name: options[:name],
        caption: options[:caption],
        picture: options[:image]
      })
    end
    
    # Start the act of listening to a resource as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def start_listen(listen)
      params = {
        song: song_url(listen.song.id, l: nil),
        end_time: listen.ended_at,
        start_time: listen.created_at
      }
      params[:playlist] = playlist_url(listen.playlist.id, l: nil) if listen.playlist
      params[:album] = album_url(listen.album.id, l: nil) if listen.album
      post('/me/music.listens', params: params)
    end
    
    # Update the act of listening to a resource as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def update_listen(listen)
      id = find_listen_by_url song_url(listen.song.id, l: nil)
      id.blank? ? start_listen(listen) : end_listen(listen)
    end
    
    # End the act of listening to a resource as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def end_listen(listen)
      id = find_listen_by_url song_url(listen.song.id, l: nil)
      return unless id
      if listen.duration < 15.seconds
        delete "/#{id}"
      else
        post "/#{id}", params: { end_time: listen.ended_at }
      end
    end
    
    # Remove the act of listening to a resource as the authenticated user.
    # Used when the user didn't listen long enough to the resource.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def delete_listen(listen)
      id = find_listen_by_url song_url(listen.song.id, l: nil)
      delete("/#{id}") if id.present?
    end
    
    # Create a new playlist as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def create_playlist(playlist)
      post '/me/music.playlists', params: {
        playlist: playlist_url(playlist.id, l: nil)
      }
    end
    
    # Update a playlist as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def update_playlist(playlist)
      id = find_playlist_by_url playlist_url(playlist.id, l: nil)
      id.blank? ? create_playlist(playlist) : get("/?id=#{id}&scrape=true")
    end
    
    # Delete a playlist as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def delete_playlist(playlist)
      id = find_playlist_by_url playlist_url(playlist.id, l: nil)
      delete("/#{id}") if id.present?
    end
    
    # Whether or not a given error message indicates that the failed submission
    # should be retried later.
    #
    # For example it could be that the service is temporarily unavailable or
    # that the credentials have expired and needs to be renewed using
    # `refresh_credentials`.
    def retry_on?(error)
      [
        "Session has expired at unix time",
        "Error validating access token:",
        "The session has been invalidated because the user has changed the password."
      ].any? do |prefix|
        error.start_with?(prefix)
      end
    end
    
    # The encrypted ID of the user.
    #
    # Allows us to link web pages or other resources to users at the backend
    # without exposing their ID to visitors.
    def encrypted_uid
      get("/dmp?fields=third_party_id")['third_party_id']
    end
    
    # The display name of the backend.
    def self.to_s
      "Facebook"
    end
    
    private
    
    # Find the ID of a listen by looking for its URL here.
    def find_listen_by_url(url)
      find_resource_by_url 'music.listens', 'song', url
    end
    
    # Find the ID of a playlist by looking for its URL here.
    def find_playlist_by_url(url)
      find_resource_by_url 'music.playlists', 'playlist', url
    end
    
    # Find the ID of a resource by looking for its URL pointing to this app.
    #
    # - `resources` is the resources to search through.   
    #    For example `music.listens`.
    #
    # - `entity` is the entity in the response to match the URL for.   
    #   For example `song` for looking at `response['data']['song']['url']`.
    #
    # - `url` is the url of the resource at this app.
    def find_resource_by_url(resources, entity, url)
      batch = 25
      offset = 0
      while true
        response = get("/me/#{resources}?limit=#{batch}&offset=#{offset}")
        return nil if response['data'].empty?
        response['data'].each do |entry|
          return entry['id'] if entry_matches?(entry, entity, url)
        end
        offset += batch
      end
      return nil
  
    rescue StandardError => e
      raise e if Rails.env.test?
      return nil
    end
    
    # Check whether an entry (from a JSON response) matches a given URL.
    #
    # - `entry` is the hash entry in the JSON response.
    #
    # - `entity` is the entity in the response to match the URL for.   
    #   For example `song` for looking at `response['data']['song']['url']`.
    #
    # - `url` is the url of the resource at this app.
    #
    # - `require_same_app` specifies whether only entries created by this web
    #    app should be considered matches.
    def entry_matches?(entry, entity, url, require_same_app = true)
      same_app = entry['application']['id'] == self.class.creds['id']
      same_url = entry['data'][entity]['url'].starts_with?(url)
      same_url and (not require_same_app or same_app)
    rescue StandardError => e
     raise e if Rails.env.test?
     false
    end
    
  end # class
  
end # module