# Copyright (c) 2015 Simplare

module Backends
  
  # The Twitter backend.
  #
  # Allows for fetching an authenticated user's data such as profile picture
  # and username.
  #
  # The backend also supports sharing content.
  class Twitter < Backends::Base
    
    # Whether or not the backend supports showing a "Follow" button.
    def can_show_button?; true; end
    
    # Whether or not shares can be submitted to Twitter.
    def can_send_shares?; true; end
    
    # The authenticated user's profile pictures.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def picture
      return user_info['profile_image_url_https']
    end
    
    # The authenticated user's fullname and username.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def names
      {
        username: user_info['screen_name'],
        fullname: user_info['name']
      }
    end
    
    # An array of the authenticated user's friends.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def friends
    end
    
    # Share a message as the authenticated user.
    #
    # Requires that `access_token` and `access_token_secret` is set.
    def share(message, options = {})
      post '/1.1/statuses/update.json', params: { status: message }
    end
    
    # The display name of the backend.
    def self.to_s
      "Twitter"
    end
    
    private
    
    def user_info
      unless @user_info
        @user_info = get "/1.1/users/show.json?user_id=#{user_id}"
      end
      @user_info
    end
    
  end # class
end # module