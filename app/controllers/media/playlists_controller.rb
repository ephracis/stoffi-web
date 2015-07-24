# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for playlists.
  class PlaylistsController < MediaController
    
    # Allow requests to `#update` to change the order of songs.
    include SortableController
    can_sort :songs
  
    # hooks
    before_action :set_resource, only: [:show, :edit, :update, :destroy, :follow]
    before_action :ensure_owner_or_admin, only: [ :edit, :update, :destroy ]
    before_action :ensure_visible, only: [ :show, :follow ]
  
    # GET /playlists
    def index
      @recent = Playlist.order(created_at: :desc).limit(limit).offset(offset)
      @weekly = Playlist.top from: 7.days.ago, limit: limit, offset: offset
      @all_time = Playlist.top limit: limit, offset: offset
    
      if user_signed_in?
        @user_follows = current_user.following(Playlist)
        @user_owns = current_user.playlists.limit(limit).offset(offset)
      end
    
      respond_with(@all_time)
    end
  
    # GET /playlists/mine.json
    def mine
      @playlists = current_user.playlists.limit(limit).offset(offset)
      respond_to do |format|
        format.json { render json: @playlists }
      end
    end
    
    # GET /playlists/following.json
    def following
      @playlists = current_user.following(Playlist)
      respond_to do |format|
        format.json { render json: @playlists }
      end
    end

    # GET /playlists/1
    def show
      @channels = ["user_#{@playlist.user.id}"]
      respond_with(@playlist, include: [ :songs ])
    end

    # GET /playlists/new
    def new
      @playlist = current_user.playlists.new
      render layout: false
    end

    # GET /playlists/1/edit
    def edit
      render layout: false
    end

    # POST /playlists
    #
    # Note: If the playlist already exists, it will be updated.
    def create
      @playlist = current_user.playlists.find_or_initialize_by name:
        params[:playlist][:name]
      @playlist.new_record? ? create_playlist : update_playlist
      respond_with @playlist
    end

    # PATCH /playlists/1
    def update
      update_playlist
      respond_with @playlist
    end

    # DELETE /playlists/1
    #
    # If `current_user` owns the playlist, it will be destroyed, otherwise it
    # will be unfollowed.
    def destroy
    
      # destroy playlist
      if current_user.owns? @playlist
        # TODO: send to connected devicesylist, request)
        current_user.links.each { |link| link.delete_playlist(@playlist) }
        @playlist.destroy
      
      # unfollow playlist
      else
        # TODO: send to connected devices
        current_user.unfollow @playlist
      end
      
      respond_with(@playlist)
    end
  
    # PUT /playlists/1/follow
    def follow
      unless current_user.follows? @playlist
        current_user.follow @playlist
        # TODO: send to connected devices
      end
      respond_with(@playlist)
    end
  
    private

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def playlist_params
      params.require(:playlist).permit(:name, :user, :is_public)
    end
    
    # Ensure that the current user is either the owner of `@playlist` or admin.
    def ensure_owner_or_admin
      unless current_user.admin? or current_user.owns?(@playlist)
        not_found('playlist') and return
      end
    end
    
    # Ensure that the current user can view `@playlist`.
    def ensure_visible
      unless @playlist.visible_to?(current_user)
        not_found('playlist') and return
      end
    end
    
    # Save `@playlist` as a new playlist.
    def create_playlist
      @playlist.assign_attributes(playlist_params)
      return unless @playlist.save
        
      # add songs to playlist
      associate_resources(:songs)
      
      # TODO: send to connected devices
      
      # send to connected links
      if @playlist.is_public and @playlist.songs.count > 0
        current_user.links.each { |l| l.create_playlist(@playlist) }
      end
      
      return true
    end
    
    # Update `@playlist`.
    def update_playlist
      
      # add/remove songs to/from playlist
      associate_resources(:songs)
      
      # update attributes
      if params[:playlist].present?
        return unless @playlist.update_attributes(playlist_params)
      end
      
      # TODO: send to connected devices
      
      # send to connected links (empty playlists are deleted)
      if @playlist.is_public and @playlist.songs.count == 0
        current_user.links.each { |l| l.delete_playlist(@playlist) }
      elsif @playlist.is_public
        current_user.links.each { |l| l.update_playlist(@playlist) }
      end
      
      return true
    end
    
  end # class
end # module