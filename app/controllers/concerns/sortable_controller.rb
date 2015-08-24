module SortableController
  extend ActiveSupport::Concern
  
  module ClassMethods
    
    def can_sort(resource)
      @sortable_model = resource.to_s.singularize
    end
    
    def sortable_model
      @sortable_model
    end
  end
  
  def sort
    if params[:format].to_sym != :json
      render text: 'only json allowed, not '+params[:format], status: :not_found and return 
      
    elsif params[self.class.sortable_model].blank?
      render json: {
        error: "missing attribute from query: #{self.class.sortable_model}"
      }, status: :unprocessable_entity and return
    end
    
    set_resource
    logger.debug "sorting #{resource.class} with id #{resource.id}"
    
    collection = self.class.sortable_model.pluralize.to_sym
    success = resource.sort collection, params[self.class.sortable_model].map(&:to_i)
    
    #SyncController.send('update', resource, request) if success
    respond_to do |format|
      if success
        format.html { redirect_to resource }
        format.json { render json: resource, status: :ok, location: resource } # TODO: render :show + jbuilder
      else
        format.html { render :edit }
        format.json { render json: resource.errors, status: :unprocessable_entity }
      end
    end
  end
end