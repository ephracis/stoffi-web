# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # The business logic for song albums.
  class AlbumsController < MediaController
    include ImageableController
    include SortableController

    can_sort :songs

    oauthenticate interactive: true, except: [:index, :show]
    before_action :ensure_admin, only: [:edit, :update, :destroy]

    # GET /albums/1
    def show
    end

    # GET /albums/1/edit
    def edit
    end

    # PATCH /albums/1
    def update
      ids = begin
              params[:songs].map(&:to_i)
            rescue
              nil
            end if params[:songs].is_a? Array
      associate_resources(:songs)
      @album.sort(:songs, ids) if ids.present?
      @album.update_attributes(album_params) if params[:album].present?

      respond_with @album
    end

    # DELETE /albums/1
    def destroy
      @album.destroy
      respond_with @album
    end

    private

    # Create an instance of the resource given the parameters.
    def set_resource
      @resource = @album = Media::Album.friendly.find params[:id]
    rescue ActiveRecord::RecordNotFound
      not_found :album
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def album_params
      params.require(:album).permit(:title)
    end
  end
end
