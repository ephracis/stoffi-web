# Copyright (c) 2015 Simplare

module Media
  
  # The business logic for sources.
  class SourcesController < ApplicationController
  
    before_action :set_source, except: :create
    before_action :ensure_admin, except: :show
    oauthenticate interactive: true, except: :show
  
    # POST /sources
    def create
      @source = Source.new(source_params)

      respond_to do |format|
        if @source.save
          format.json { render :show, status: :created, location: @source }
          format.js { }
        else
          format.json { render json: @source.errors, status: :unprocessable_entity }
          format.js { render partial: 'shared/errors', locals: { resource: @source, action: :create } }
        end
      end
    end
  
    # PATCH/PUT /sources/1
    def update
      respond_to do |format|
        if @source.update(source_params)
          format.json { render :show, status: :ok, location: @source }
          format.js { }
        else
          format.json { render json: @source.errors, status: :unprocessable_entity }
          format.js { render partial: 'shared/errors', locals: { resource: @source, action: :update } }
        end
      end
    end
  
    # DELETE /sources/1
    def destroy
      @source.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_source
      not_found('source') and return unless Source.exists? params[:id]
      @source = Source.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_params
      params.require(:source).permit(:name, :foreign_url, :foreign_id, :resource_id, :resource_type)
    end
  end
end