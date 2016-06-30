# frozen_string_literal: true
module SortableController
  extend ActiveSupport::Concern

  # Static class methods.
  module ClassMethods
    def can_sort(resource)
      @sortable_model = resource.to_s.singularize
    end

    def sortable_model
      @sortable_model
    end
  end

  # FIXME: accept new order when editing

  def sort
    if params[:format].to_sym != :json
      render(text: 'only json allowed, not ' +
                   params[:format], status: :not_found) && return

    elsif params[self.class.sortable_model].blank?
      render(json: {
               error: 'missing attribute from query: ' +
                      self.class.sortable_model
             }, status: :unprocessable_entity) && return
    end

    set_resource
    logger.debug "sorting #{resource.class} with id #{resource.id}"

    # TODO: pluralize param key
    collection = self.class.sortable_model.pluralize.to_sym
    success = resource.sort collection,
                            params[self.class.sortable_model].map(&:to_i)

    respond_to do |format|
      if success
        format.html { redirect_to resource }
        format.json { render :show }
      else
        format.html { render :edit }
        format.json do
          render json: resource.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
