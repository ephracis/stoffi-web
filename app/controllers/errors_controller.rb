# Copyright (c) 2015 Simplare

# Handle requests which are erroneous.
class ErrorsController < ApplicationController
  
  def show
    @code = status_code
    
    if @code.to_i == 404
      @resource = "page"
      render '404', status: :not_found
      
    else
      render 'show', status: @code.to_i, layout: 'empty'
    end
  end
  
  protected
  
  def status_code
    params[:code] || 500
  end
  
end