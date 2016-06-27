# Copyright (c) 2015 Simplare

module Accounts

  # A link between a user and a third party account.
  class Link < ActiveRecord::Base
    
    # concerns
    include Base

    # associations
    belongs_to :user
    has_many :backlogs, dependent: :destroy, class_name: "LinkBacklog"
  
    # validations
    validates :provider, presence: true
  
    # The string to display to users for representing the resource.
    def to_s
      self.class.pretty_name(provider)
    end
    alias_method :display, :to_s
  
    # Update the authentication credentials from a hash.
    #
    # The hash should follow the format as what's returned from the `omniauth`
    # gem after successful authentication.
    # 
    # After update, all failed submissions in the backlog will be retried.
    def update_credentials(auth)
      exp = auth['credentials']['expires_at']
      exp = DateTime.strptime("#{exp}",'%s') if exp
      self.update_attributes(
        access_token: auth['credentials']['token'],
        access_token_secret: auth['credentials']['secret'],
        refresh_token: auth['credentials']['refresh_token'],
        token_expires_at: exp
      )
      retry_failed_submissions
    end
    
    %w[listens shares playlists button].each do |resources|
      define_method "#{resources}?" do
        backend.send("#{resources}?")
      end
      
      define_method "#{resources}_enabled?" do
        send("enable_#{resources}") and send("#{resources}?")
      end
    end
    
    # The user's profile picture on the third party account.
    def picture
      backend.picture
    end
    
    # The user's name on the third party account.
    def name
      backend.name
    end
      
    # The most recent error message in the `backlog`.
    def error
      backlogs.order(:created_at).last.error if backlogs.count > 0
    end
    
    # Share a resource.
    def share(message = nil, backend_options = {})
      backend.share(message, backend_options) if shares?
    end
      
    # Let the service know that the user has started to play a song.
    def start_listen(l)
      backend.start_listen(l) if listens?
    rescue Exception => e
      catch_error(l, e)
    end
      
    # Let the service know that the user has paused, resumed, or otherwise
    # updated a currently active song.
    def update_listen(l)
      backend.update_listen(l) if listens?
    rescue Exception => e
      catch_error(l, e)
    end
      
    # Let the service know that the user has stopped listen to a song.
    def end_listen(l)
      backend.end_listen(l) if listens?
    rescue Exception => e
      catch_error(l, e)
    end
      
    # Remove that a song was listened to on the service.
    #
    # Used when the song was skipped or not played for long enough.
    def delete_listen(l)
      backend.delete_listen(l) if listens?
    end
      
    # Let the service know that the user just created a playlist.
    def create_playlist(p)
      backend.create_playlist(p) if playlists?
    rescue Exception => e
      catch_error(p, e)
    end
      
    # Let the service know that the user just updated a playlist.
    def update_playlist(p)
      backend.update_playlist(p) if playlists?
    rescue Exception => e
      catch_error(p, e)
    end
      
    # Let the service know that the user just removed a playlist.
    def delete_playlist(p)
      backend.delete_playlist(p) if playlists?
    end
    
    def encrypted_uid
      unless super
        update_attribute(:encrypted_uid, backend.encrypted_uid)
      end
      super
    end
  
    # A list of services currently supported.
    def self.available
      [
        { name: "Twitter" },
        { name: "Facebook" },
        { name: "Google", slug: "google_oauth2" },
        { name: "Vimeo" },
        { name: "SoundCloud" },
        { name: "Last.fm", slug: :lastfm, icon: :lastfm },
        { name: "Weibo" },
        { name: "Windows Live", slug: :windowslive }
      ]
    end
  
    # The display name of a given provider.
    def self.pretty_name(provider)
      case provider
      when "google_oauth2" then "Google"
      when "linked_in" then "LinkedIn"
      when "soundcloud" then "SoundCloud"
      when "lastfm" then "Last.fm"
      when "myspace" then "MySpace"
      when "linkedin" then "LinkedIn"
      when "vkontakte" then "vKontakte"
      when "windowslive" then "Live"
      else provider.titleize
      end
    end
    
    private
    
    # Get the backend of the link.
    def backend
      unless @backend
        begin
          @backend = "Backends::#{provider.camelize}".constantize.new
        rescue
          @backend = Backends::Base.new
        end
      end
      
      # Some backends uses a `refresh_token` to limit the validity of the
      # `access_token`. If the `access_token` has expired, a new one must be
      # retrieved using the `refresh_token`.
      if refresh_token and token_expires_at < DateTime.now
        update_attributes backend.refresh_credentials(refresh_token)
      end
      
      @backend.access_token = access_token
      @backend.access_token_secret = access_token_secret
      @backend.user_id = uid
      
      @backend
    end
    
    # Go through the `backlog` and retry the failed submissions.
    def retry_failed_submissions
      retried = []
      self.backlogs.each do |backlog|
        next unless backlog.resource
      
        # only resubmit each resource once
        next if retried.include? backlog.resource
        
        retry_failed_submission(backlog.resource)
        retried << backlog.resource
      end
    
      # clear pending submissions
      self.backlogs.destroy_all
    end
    
    # Retry a specific failed submission of a given resource.
    def retry_failed_submission(resource)
      case resource.class.name
        
      when 'Share' then
        share(resource)
        
      when 'Media::Listen'
        update_listen(resource)
        
      when 'Media::Playlist'
        update_playlist(resource)
        
      end
    end
      
    # Catch an exception that has occured when trying to send a resource to the
    # backend service.
    #
    # This will save the resource and its exception onto the backlog, for later
    # retries.
    def catch_error(resource, exception)
      raise exception if Rails.env.test?
      
      # extract error message from JSON response
      json = JSON.parse exception.message.split("\n")[1]
      error = json['error']['message']
      
      # create and save new backlog item if backend thinks we should
      bl = self.backlogs.new(resource: resource, error: error)
      bl.save if backend.retry_on?(error)
    rescue Exception => e
      raise e if Rails.env.test?
      logger.error "failed to catch error: #{exception.message}"
    end
    
    
    
    
    
    
    ################### OLD ###################
  
    # # Whether or not a user profile picture can be extracted from the third party account.
    # def picture?
    #   provider.in? ["twitter", "facebook", "google_oauth2", "lastfm", "vimeo"]
    # end
    #   
    # # Whether or not the third party has a social button.
    # def can_button?
    #   provider.in? ["twitter", "google_oauth2"]
    # end
    #   
    # # Whether or not to show a social button.
    # def button?
    #   can_button? and show_button
    # end
    #   
    # # Whether or not stuff can be shared with the third party account.
    # def can_share?
    #   
    # end
    # 
    # # Whether or not to share stuff with the third party account.
    # def share?
    #   !Rails.env.development? and do_share && can_share?
    # end
    #   
    # # Whether or not listens can be shared with the third party account.
    # def can_listen?
    #   
    # end
    #   
    # # Whether or not to share listens with the third party account.
    # def listen?
    #   !Rails.env.development? and do_listen && can_listen?
    # end
    #   
    # # Whether or not donations can be shared with the third party account.
    # def can_donate?
    #   provider.in? ["facebook", "twitter"]
    # end
    #   
    # # Whether or not to share donations with the third party account.
    # def donate?
    #   !Rails.env.development? and do_donate && can_donate?
    # end
    #   
    # # Whether or not playlists can be kept and synchronized with the third party account.
    # def can_create_playlist?
    #   provider.in? ["facebook", "lastfm"]
    # end
    #   
    # # Whether or not to keep and synchronize playlists with the third party account.
    # def create_playlist?
    #   !Rails.env.development? and do_create_playlist && can_create_playlist?
    # end
    #   
    # # The user's profile picture on the third party account.
    # def picture
    #   case provider
    #   when "facebook"
    #     response = get("/me/picture?type=large&redirect=false")
    #     return response['data']['url']
    #   
    #   when "twitter"
    #     response = get("/1.1/users/show.json?user_id=#{uid}")
    #     return response['profile_image_url_https']
    #   
    #   when "google_oauth2"
    #     response = get("/oauth2/v1/userinfo")
    #     return response['picture'] if response['picture']
    #   
    #   when "myspace"
    #     response = get("/v1.0/people/@me")
    #     return response['thumbnailUrl'] if response['thumbnailUrl']
    #   
    #   when "vimeo"
    #     response = get("/api/v2/#{uid}/info.json")
    #     return response['portrait_medium']
    #   
    #   when "yahoo"
    #     response = get("/v1/user/#{uid}/profile/tinyusercard")
    #     return response['profile']['image']['imageUrl']
    #   
    #   when "vkontakte"
    #     response = get("api.php?method=getProfiles?uids=#{uid}&fields=photo_medium")
    #     return response['Response'][0]['Photo']
    #   
    #   when "lastfm"
    #     response = get("/2.0/?method=user.getinfo&format=json&user=#{uid}&api_key=#{creds['id']}")
    #     return response['user']['image'][1]['#text']
    #   
    #   when "linkedin"
    #     response = get("/v1/people/~")
    #     logger.debug response.inspect
    #     #return ???
    #   
    #   when "windowslive"
    #     response = get("/v5.0/me/picture?access_token=#{access_token}")
    #     return response['person']['picture_url']
    #   
    #   end
    #   return nil
    # end
    #   
    # # The user's names on the third party account.
    # #
    # # Returns a hash of <tt>fullname</tt> and/or <tt>username</tt>.
    # def names
    #   case provider
    #   when "facebook"
    #     response = get("/me?fields=name,username")
    #     r = { fullname: response['name'] }
    #     r[:username] = response['username'] if response['username'] != nil
    #     return r
    #   
    #   when "twitter"
    #     response = get("/1.1/users/show.json?user_id=#{uid}")
    #     return {
    #       username: response['screen_name'],
    #       fullname: response['name']
    #     }
    #   
    #   when "google_oauth2"
    #     response = get("/oauth2/v1/userinfo")
    #     return {
    #       fullname: response['name'],
    #       username: response['email'].split('@',2)[0]
    #     }
    #   
    #   when "vimeo"
    #     response = get("/api/v2/#{uid}/info.json")
    #     return { fullname: response['display_name'] }
    #   
    #   when "lastfm"
    #     response = get("/2.0/?method=user.getinfo&format=json&user=#{uid}&api_key=#{creds['id']}")
    #     return {
    #       username: response['user']['name'],
    #       fullname: response['user']['realname']
    #     }
    #   
    #   end
    #   return {}
    # end
    #   
    # # Share a resource on the service.
    # def share(s)
    #   return unless share?
    # 
    #   if s.resource.is_a?(Song)
    #     # fix message to either
    #     #  - the user's message
    #     #  - title by artist
    #     #  - title
    #     msg = s.message
    #     if msg.to_s == ""
    #       msg = s.resource.title
    #       a = s.resource.artists.collect { |x| x.name }.to_sentence
    #       msg += " by #{a}" unless a.to_s == ""
    #     end
    #   
    #   elsif s.resource.is_a?(Playlist)
    #     # fix message to either
    #     #  - the user's message
    #     #  - playlist by user
    #     msg = s.message
    #     if msg.to_s == ""
    #       msg = "#{s.resource.name} by #{s.resource.user.name}"
    #     end
    #   end
    # 
    #   begin
    #     case [provider, s.resource_type]
    #     when ["facebook", "Song"]
    #       share_song_on_facebook(s, msg)
    #   
    #     when ["facebook", "Playlist"]
    #       share_playlist_on_facebook(s, msg)
    #     
    #     when ["twitter", "Song"]
    #       share_song_on_twitter(s, msg)
    #   
    #     when ["twitter", "Playlist"]
    #       share_playlist_on_twitter(s, msg)   
    #     end
    #   rescue Exception => e
    #     catch_error(s, e)
    #   end
    # end
    #   
    # # Let the service know that the user has started to play a song.
    # def start_listen(l)
    #   return unless listen?
    # 
    #   begin
    #     case provider
    #     when "facebook"
    #       start_listen_on_facebook(l)
    #     when "lastfm"
    #       start_listen_on_lastfm(l)
    #     end
    #   rescue Exception => e
    #     catch_error(l, e)
    #   end
    # end
    #   
    # # Let the service know that the user has paused, resumed, or otherwise updated a currently active song.
    # def update_listen(l)
    #   return unless listen?
    # 
    #   begin
    #     case provider
    #     when "facebook"
    #       update_listen_on_facebook(l)
    #     end
    #   rescue Exception => e
    #     catch_error(l, e)
    #   end
    # end
    #   
    # # Let the service know that the user has stopped listen to a song.
    # def end_listen(l)
    #   return unless listen?
    # 
    #   begin
    #     case provider
    #     when "lastfm"
    #       end_listen_on_lastfm(l)
    #     when "facebook"
    #       end_listen_on_facebook(l)
    #     end
    #   rescue Exception => e
    #     catch_error(l, e)
    #   end
    # end
    #   
    # # Remove that a song was listened to on the service.
    # #
    # # Used when the song was skipped or not played for long enough.
    # def delete_listen(l)
    #   return unless listen?
    #   case provider
    #   when "facebook"
    #     delete_listen_on_facebook(l)
    #   end
    # rescue Exception => e
    #   logger.debug e.inspect
    # end
    #   
    # # Let the service know that the user just created a playlist.
    # def create_playlist(p)
    #   return unless create_playlist?
    #   case provider
    #   when "facebook"
    #     create_playlist_on_facebook(p)
    #   end
    # rescue Exception => e
    #   catch_error(p, e)
    # end
    #   
    # # Let the service know that the user just updated a playlist.
    # def update_playlist(p)
    #   return unless create_playlist?
    #   case provider
    #   when "facebook"
    #     update_playlist_on_facebook(p)
    #   end
    #   
    # rescue Exception => e
    #   catch_error(p, e)
    # end
    #   
    # # Let the service know that the user just removed a playlist.
    # def delete_playlist(p)
    #   return unless create_playlist?
    #   case provider
    #   when "facebook"
    #     delete_playlist_on_facebook(p)
    #   end
    # end
    #   
    # # Get an encrypted ID of the user at the third party.
    # #
    # # Currently used by Facebook to allow link to the user profile in open graph tags.
    # def fetch_encrypted_uid
    #   case provider
    #   when "facebook"
    #     fetch_encrypted_facebook_uid
    #   end
    # end
    #   
    # private
    # 
    # #include Links::Facebook
    # #include Links::Twitter
    # #include Links::Lastfm
    #   
    # # Send an authorized GET request to the service.
    # def get(path, params = {})
    #   request(path, :get, params)
    # end
    #   
    # # Send an authorized POST request to the service.
    # def post(path, params = {})
    #   request(path, :post, params)
    # end
    #   
    # # Send an authorized DELETE request to the service.
    # def delete(path)
    #   request(path, :delete)
    # end
    #   
    # # Send an authorized request to the service.
    # def request(path, method = :get, params = {})
    #   
    #   # google uses a refresh_token
    #   # we need to request a new access_token using the
    #   # refresh_token if it has expired
    #   if provider == "google_oauth2" and refresh_token and token_expires_at < DateTime.now
    #     http = Net::HTTP.new("accounts.google.com", 443)
    #     http.use_ssl = true
    #     res, data = http.post("/o/oauth2/token", 
    #     {
    #       refresh_token: refresh_token,
    #       client_id: creds['id'],
    #       client_secret: creds['key'],
    #       grant_type: 'refresh_token'
    #     }.map { |k,v| "#{k}=#{v}" }.join('&'))
    #     response = JSON.parse(data)
    #     exp = response['expires_in'].seconds.from_now
    #     update_attributes({ token_expires_at: exp, access_token: response['access_token']})
    #   end
    # 
    #   if provider == "twitter"
    #     client = OAuth::Consumer.new(creds['id'], creds['key'],
    #       {
    #         site: creds['url'],
    #         ssl: {ca_path: "/etc/ssl/certs"},
    #         scheme: :header
    #       })
    #     token_hash = {
    #       oauth_token: access_token,
    #       oauth_token_secret: access_token_secret
    #     }
    #     token = OAuth::AccessToken.from_hash(client, token_hash)
    #     logger.debug params.inspect
    #     resp = token.request(method, creds['url'] + path, params[:params])
    #     return JSON.parse(resp.body)
    #   else
    #     client = OAuth2::Client.new(creds['id'], creds['key'], site: creds['url'], ssl: {ca_path: "/etc/ssl/certs"})
    #     token = OAuth2::AccessToken.new(client, access_token, header_format: "OAuth %s")
    #   
    #     case method
    #     when :get
    #       return token.get(path).parsed
    #   
    #     when :post
    #       return token.post(path, params).parsed
    # 
    #     when :delete
    #       return token.delete(path).parsed
    #     end
    #   end
    # end
    #
    # Catch an exception that occured when sending a resource to Facebook.
    #
    # This uses the exception message to decide if the resource should be saved in
    # the backlog for later retries.
    # def catch_facebook_error(resource, message)
    #   if message.start_with? "Session has expired at unix time" or
    #      message.start_with? "Error validating access token:" or
    #      message == "The session has been invalidated because the user has changed the password."
    #      bl = self.backlogs.new
    #      bl.resource = resource
    #      bl.error = message
    #      bl.save
    #   end
    # end
    #   
    # # The API credentials for Stoffi to authenticate with the service.
    # def creds
    #   Rails.application.secrets.oa_cred[provider]
    # end
  end
end
