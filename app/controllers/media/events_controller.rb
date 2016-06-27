# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for events.
  class EventsController < MediaController
    include ImageableController
  
    before_action :ensure_admin, except: [ :index, :show, :create ]
    oauthenticate interactive: true, except: [ :index, :show ]

    # GET /events/1
    def show
    end

    # POST /events
    def create
      @event = Event.new(event_params)

      respond_to do |format|
        if @event.save
          format.html { redirect_to @event }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new }
          format.json { render json: @event.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # PATCH /events/1
    def update
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to @event }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit }
          format.json { render json: @event.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # DELETE /events/1
    def destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to events_url }
        format.json { head :no_content }
      end
    end

    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = @event = Media::Event.friendly.find params[:id]
    rescue ActiveRecord::RecordNotFound
      not_found :event
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def event_params
      params.require(:event).permit(:name, :venue, :latitude, :longitude,
        :start, :stop, :content, :category)
    end
  end
end
