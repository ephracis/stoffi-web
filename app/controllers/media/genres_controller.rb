# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for genres.
  class GenresController < ApplicationController
    include ImageableController
  
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :ensure_admin, only: [ :update, :destroy ]
    oauthenticate interactive: true, except: [ :index, :show ]

    # GET /genres
    def index
      l, o = pagination_params
      @recent = Listen.order(created_at: :desc).offset(o).limit(l).
        map { |x| x.song.genres }.flatten.uniq
      @weekly = Genre.top from: 7.days.ago, offset: o, limit: l
      @all_time = Genre.top offset: o, limit: l
    
      if user_signed_in?
        @user_recent = current_user.listens.order(created_at: :desc).
          offset(o).limit(l).map(&:song).map(&:genres).flatten.uniq
        @user_weekly = Genre.top for: current_user, from: 7.days.ago,
          offset: o, limit: l
        @user_all_time = Genre.top for: current_user, offset: o, limit: l
      end
    end

    # GET /genres/1
    def show
    end

    # POST /genres
    def create
      @genre = Genre.new(genre_params)

      respond_to do |format|
        if @genre.save
          format.html { redirect_to @genre }
          format.json { render :show, status: :created, location: @genre }
        else
          format.html { render :new }
          format.json { render json: @genre.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /genres/1
    def update
      respond_to do |format|
        if @genre.update(genre_params)
          format.html { redirect_to @genre }
          format.json { render :show, status: :ok, location: @genre }
        else
          format.html { render :edit }
          format.json { render json: @genre.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /genres/1
    def destroy
      @genre.destroy
      respond_to do |format|
        format.html { redirect_to genres_url }
        format.json { head :no_content }
      end
    end

    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      not_found('genre') and return unless Genre.exists? params[:id]
      @genre = Genre.find(params[:id])
    end
  
    # Access the resource for this controller.
    def resource
      @genre
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def genre_params
      params.require(:genre).permit(:name)
    end
  end
end