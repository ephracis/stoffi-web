# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for song albums.
  class AlbumsController < MediaController
    include ImageableController
    include SortableController
  
    can_sort :songs
  
    oauthenticate interactive: true, except: [ :index, :show ]
    before_action :ensure_admin, only: [ :edit, :update, :destroy ]
  
    # GET /albums
    def index
      @recent = Listen.order(created_at: :desc).where(:album).limit(limit).
        offset(offset).map(&:album)
      @weekly = Album.top from: 7.days.ago, limit: limit, offset: offset
      @all_time = Album.top limit: limit, offset: offset
    
      if user_signed_in?
        @user_recent = current_user.listens.order(created_at: :desc).
          where(:album).limit(limit).offset(offset).map(&:album)
        @user_weekly = Album.top for: current_user, from: 7.days.ago,
          limit: limit, offset: offset
        @user_all_time = Album.top for: current_user, limit: limit,
          offset: offset
      end
    
      respond_with @all_time
    end

    # GET /albums/1
    def show
      @album.paginate_songs limit, offset
      respond_with @album, methods: [ :paginated_songs ]
    end

    # GET /albums/1/edit
    def edit
      render layout: false
    end

    # PATCH /albums/1
    def update
      associate_resources(:songs)
      success = true
      if params[:album].present?
        success = @album.update_attributes(album_params) 
      end
      
      respond_with @album
    end

    # DELETE /albums/1
    def destroy
      @album.destroy
      respond_with @album
    end
  
    private

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def album_params
      params.require(:album).permit(:title)
    end
  end
end