# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for artists.
  class ArtistsController < MediaController
    include ImageableController

    oauthenticate interactive: true, except: [ :index, :show ]
    before_filter :ensure_admin, except: [ :index, :show ]

    def show
      l, o = pagination_params
      @artist.paginate_songs(l, o)
      respond_with(@artist, methods: [ :paginated_songs ])
    end

    def update
      @artist.update(artist_params)
      respond_with(@artist)
    end

    def destroy
      @artist.destroy
      respond_with(@artist)
    end
  
    private
    
    # Create an instance of the resource given the parameters.
    def set_resource
      @resource = @artist = Media::Artist.friendly.find params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artist_params
      params.require(:artist).permit(:name)
    end
  end
end
