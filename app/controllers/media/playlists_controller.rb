# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # The business logic for playlists.
  class PlaylistsController < MediaController
    # Allow requests to `#update` to change the order of songs.
    include SortableController
    can_sort :songs

    # hooks
    before_action :set_resource,
                  only: [:show, :edit, :update, :destroy, :follow]
    before_action :ensure_owner_or_admin, only: [:edit, :update, :destroy]
    before_action :ensure_visible, only: [:show, :follow]
    before_action :set_breadcrumb, only: [:show, :edit]

    # GET /playlists
    def index
    end

    # GET /playlists/1
    def show
    end

    # GET /playlists/new
    def new
      @playlist = current_user.playlists.new
      breadcrumbs.clear
      add_breadcrumb I18n.t('breadcrumbs.home'), '/'
      add_breadcrumb I18n.t('breadcrumbs.playlists'), playlists_path
      add_breadcrumb I18n.t('breadcrumbs.new'), new_playlist_path(current_user)
    end

    # GET /playlists/1/edit
    def edit
    end

    # POST /playlists
    #
    # Note: If the playlist already exists, it will be updated.
    def create
      @playlist = current_user.playlists.find_or_initialize_by name:
        params[:playlist][:name]

      if @playlist.new_record?
        success = create_playlist

      else
        # merge songs if updating existing
        params[:songs] = { added: params[:songs] } if params[:songs].is_a? Array
        success = update_playlist
      end

      respond_to do |format|
        if success
          format.html { redirect_to @playlist }
          format.json { render :show, status: :created, location: @playlist }
        else
          format.html { render :new }
          format.json do
            render json: @playlist.errors,
                   status: :unprocessable_entity
          end
        end
      end
    end

    # PATCH /playlists/1
    def update
      success = update_playlist

      if params[:songs].present? && params[:songs][:added].present?
        @playlist.add_songs_activity current_user,
                                     params[:songs][:added]
      end
      if params[:songs].present? && params[:songs][:removed].present?
        @playlist.remove_songs_activity current_user,
                                        params[:songs][:removed]
      end

      respond_to do |format|
        if success
          format.html { redirect_to playlist_url(@playlist) }
          format.json { render :show, status: :ok, location: @playlist }
        else
          format.html { render :edit }
          format.json do
            render json: @playlist.errors,
                   status: :unprocessable_entity
          end
        end
      end
    end

    # DELETE /playlists/1
    #
    # If `current_user` owns the playlist, it will be destroyed, otherwise it
    # will be unfollowed.
    def destroy
      # destroy playlist
      if current_user.owns? @playlist
        current_user.links.each { |link| link.delete_playlist(@playlist) }
        @playlist.destroy
        return_to = playlists_url

      # unfollow playlist
      else
        current_user.unfollow @playlist
        return_to = playlist_url @playlist
      end

      respond_to do |format|
        format.html { redirect_to return_to }
        format.json { head :no_content }
      end
    end

    # PUT /playlists/1/follow
    def follow
      current_user.follow @playlist unless current_user.follows? @playlist
      respond_to do |format|
        format.html { redirect_to @playlist }
        format.json { render :show, status: :ok, location: @playlist }
      end
    end

    private

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def playlist_params
      params.require(:playlist).permit(:name, :user, :is_public, :slug, :songs,
                                       :filter)
    end

    # Ensure that the current user is either the owner of `@playlist` or admin.
    def ensure_owner_or_admin
      unless current_user.admin? || current_user.owns?(@playlist)
        not_found('playlist') && return
      end
    end

    # Ensure that the current user can view `@playlist`.
    def ensure_visible
      not_found('playlist') && return unless @playlist.visible_to?(current_user)
    end

    # Save `@playlist` as a new playlist.
    def create_playlist
      @playlist.assign_attributes(playlist_params)
      return false unless @playlist.save

      # add songs to playlist
      associate_resources(:songs)

      # send to connected links
      if @playlist.is_public && @playlist.songs.count > 0
        current_user.links.each { |l| l.create_playlist(@playlist) }
      end

      true
    end

    # Update `@playlist`.
    def update_playlist
      ids = begin
              params[:songs].map(&:to_i)
            rescue
              nil
            end if params[:songs].is_a? Array

      # add/remove songs to/from playlist
      associate_resources :songs

      @playlist.sort :songs, ids if ids.present?

      # update attributes
      if params[:playlist].present?
        return false unless @playlist.update(playlist_params)
      end

      # send to connected links (empty playlists are deleted)
      if @playlist.is_public && @playlist.songs.count == 0
        current_user.links.each { |l| l.delete_playlist(@playlist) }
      elsif @playlist.is_public
        current_user.links.each { |l| l.update_playlist(@playlist) }
      end

      true
    end

    # Attempt to create an instance of the playlist given the parameters.
    def set_resource
      # find user
      if User.friendly.exists? params[:user_slug]
        user = User.friendly.find params[:user_slug]
      else
        not_found('user') && return
      end

      # find playlist
      if user.playlists.friendly.exists? params[:playlist_slug]
        @resource = user.playlists.friendly.find params[:playlist_slug]
      else
        not_found('playlist') && return
      end

      @playlist = @resource
    end

    def set_breadcrumb
      breadcrumbs.clear
      add_breadcrumb I18n.t('breadcrumbs.home'), '/'
      add_breadcrumb @playlist.user, user_path(@playlist.user)
      add_breadcrumb @playlist, playlist_path(@playlist)
      if action_name.to_sym == :edit
        add_breadcrumb I18n.t('breadcrumbs.edit'),
                       edit_playlist_path(@playlist)
      end
    end
  end # class
end # module
