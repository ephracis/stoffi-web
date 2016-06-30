# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # The business logic for songs.
  class SongsController < MediaController
    include DuplicatableController
    include ImageableController

    before_action :ensure_admin, except: [:index, :show, :create, :destroy]

    can_duplicate Media::Song
    oauthenticate interactive: true, except: [:index, :show]

    # GET /songs/1
    def show
      @resource = @song = @song.dedup if params[:dedup].present?
    end

    # GET /songs/new
    def new
      redirect_to songs_path
    end

    # GET /songs/1/edit
    def edit
    end

    # POST /songs
    def create
      @song = Song.get_by_path(params[:song][:path])
      @song = current_user.songs.new(params[:song]) unless @song

      if current_user.songs.find_all_by_id(@song.id).count == 0
        current_user.songs << @song
      end

      @song.save
      respond_with(@song)
    end

    # PUT /songs/1
    def update
      associate_resources :artists, params: true

      respond_to do |format|
        if @song.update_attributes(song_params)
          format.html { redirect_to @song }
          format.js {}
          format.json { render json: @song, location: @song }
        else
          format.html { render action: 'edit' }
          format.js do
            render partial: 'shared/dialog/errors', locals:
              { resource: @song, action: :update }
          end
          format.json do
            render json: @song.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # DELETE /songs/1
    def destroy
      respond_with(@song)
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      unless Song.unscoped.friendly.exists? params[:id]
        not_found('song') && return
      end
      @resource = @song = Song.unscoped.friendly.find params[:id]
    end

    # Access the resource for this controller.
    def resource
      @song
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def song_params
      params.require(:song).permit(:title, :genres, :genre, :artists, :slug,
                                   :archetype_id, :archetype_type)
    end
  end
end
