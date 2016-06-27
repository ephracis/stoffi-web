# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for genres.
  class GenresController < MediaController
    include ImageableController
  
    before_action :ensure_admin, except: [ :index, :show, :create ]
    oauthenticate interactive: true, except: [ :index, :show ]

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
      @resource = @genre = Media::Genre.friendly.find params[:id]
    rescue ActiveRecord::RecordNotFound
      not_found :genre
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def genre_params
      params.require(:genre).permit(:name)
    end
  end
end
