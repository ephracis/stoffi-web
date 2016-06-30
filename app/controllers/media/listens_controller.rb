# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # The business logic for listens to songs.
  class ListensController < ApplicationController
    oauthenticate
    respond_to :html, :mobile, :embedded, :xml, :json

    # GET /listens
    def index
      l, o = pagination_params
      @listen = current_user.listens.new
      @listens = current_user.listens.limit(l).offset(o)
      respond_with @listens
    end

    # GET /listens/by/1
    def by
      l, o = pagination_params
      params[:user_id] = process_me(params[:user_id])
      id = logged_in? ? current_user.id : -1
      @user = User.find(params[:user_id])

      if !current_user.nil? && params[:user_id] == current_user.id
        @listens = current_user.listens.limit(l).offset(o)
      else
        @listens = Listen.where('user_id = ? AND is_public = 1',
                                params[:user_id]).limit(l).offset(o)
      end

      @channels = ["user_#{id}"]

      respond_with(@listens)
    end

    # GET /listens/1
    def show
      @listen = current_user.listens.find(params[:id])
      respond_with @listen
    end

    # GET /listens/new
    def new
      @listen = current_user.listens.new
      respond_with @listen
    end

    # GET /listens/1/edit
    def edit
      @listen = current_user.listens.find(params[:id])
    end

    # POST /listens
    def create
      @listen = current_user.listens.new(params[:listen])

      if params[:playlist].present?
        playlist = Playlist.get(current_user, params[:playlist])
      end
      if params[:track] && params[:track][:artist].present?
        artist = Artist.get(params[:track][:artist])
      end
      album = Album.get(params[:album]) if params[:album].present?
      song = Song.get(current_user,
                      title: params[:track][:title],
                      path: params[:track][:path],
                      length: params[:track][:length],
                      foreign_url: params[:track][:foreign_url],
                      art_url: params[:track][:art_url],
                      genre: params[:track][:genre]) if params[:track]

      album.songs << song if song && album && album.songs.find(song.id).nil?
      artist.songs << song if song && artist && artist.songs.find(song.id).nil?
      if artist && album && artist.albums.find(album.id).nil?
        artist.albums << album
      end

      @listen.song = song unless @listen.song
      @listen.playlist = playlist if playlist
      @listen.album = album if album
      @listen.device = @current_device

      @listen.playlist.songs << @listen.song if @listen.playlist
      current_user.songs << @listen.song

      @listen.started_at = Time.current unless @listen.started_at
      unless @listen.ended_at
        @listen.ended_at = @listen.started_at + @listen.song.length
      end

      success = @listen.save

      if success
        SyncController.send('create', @listen, request)
        current_user.links.each { |link| link.start_listen(@listen) }
      end

      respond_with @listen
    end

    # PUT /listens/1
    def update
      @listen = current_user.listens.find(params[:id])
      success = @listen.update_attributes(params[:listen])
      if success
        SyncController.send('update', @listen, request)
        if params[:listen].key? :ended_at
          current_user.links.each { |link| link.update_listen(@listen) }
        end
      end
      respond_with @listen
    end

    # DELETE /listens/1
    def destroy
      @listen = current_user.listens.find(params[:id])
      current_user.links.each { |link| link.delete_listen(@listen) }
      SyncController.send('delete', @listen, request)
      @listen.destroy
      respond_with @listen
    end

    # POST /listens/1/end
    def end
      @listen = current_user.listens.find(params[:id])
      @listen.update_attribute(:ended_at, Time.current)
      current_user.links.each { |link| link.end_listen(@listen) }
      respond_with @listen
    end
  end
end
