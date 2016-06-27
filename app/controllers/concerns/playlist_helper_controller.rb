module PlaylistHelperController
  extend ActiveSupport::Concern
  
  included do

    # Override the `playlist_path` and allow the user to be inferred from
    # the playlist.
    #
    # Example:
    #
    #     playlist_path playlist # now works
    #     playlist_path playlist.user, playlist # still works
    #
    def playlist_path(user, playlist = nil, options = {})
      if playlist.is_a? Hash
        options = playlist
        playlist = nil
      end
      playlist = user if playlist.blank?
      super(playlist.user, playlist, options)
    end
    helper_method :playlist_path if respond_to? 'helper_method'

    # Override the `playlist_url` and allow the user to be inferred from
    # the playlist.
    #
    # Example:
    #
    #     playlist_url playlist # now works
    #     playlist_url playlist.user, playlist # still works
    #
    def playlist_url(user, playlist = nil, options = {})
      if playlist.is_a? Hash
        options = playlist
        playlist = nil
      end
      playlist = user if playlist.blank?
      super(playlist.user, playlist, options)
    end
    helper_method :playlist_url if respond_to? 'helper_method'
    
    
    
    
    
    def edit_playlist_path(user, playlist = nil, options = {})
      if playlist.is_a? Hash
        options = playlist
        playlist = nil
      end
      playlist = user if playlist.blank?
      super(playlist.user, playlist, options)
    end
    helper_method :edit_playlist_path if respond_to? 'helper_method'
  
  end
  
end