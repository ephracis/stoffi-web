# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # Logic for managing images.
  class ImagesController < ApplicationController
    before_action :ensure_admin
    before_action :set_resource, only: [:show, :edit, :update, :destroy]

    # GET /:resource/images
    def index
      @resource = imageable_resource
    end

    # GET /:resource/images/:id
    def show
    end

    # GET /:resource/images/new
    def new
      @image = Image.new
      @image.resource = imageable_resource
    end

    # POST /:resource/images
    def create
      @image = Image.new(image_params)

      respond_to do |format|
        if @image.save
          format.html { redirect_to @image.resource }
          format.json { render :show, status: :created, location: @image }
        else
          format.html { render :new }
          format.json do
            render json: @image.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # GET /:resource/images/:id/edit
    def edit
    end

    # PATCH /:resource/images/:id
    def update
      respond_to do |format|
        if @image.update(image_params)
          format.html do
            redirect_to @image.resource, flash:
              { success: t('media.images.update.success') }
          end
          format.json { render :show, status: :ok, location: @image }
        else
          format.html { render 'edit' }
          format.json do
            render json: @image.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # DELETE /:resource/images/:id
    def destroy
      resource = @image.resource
      @image.destroy
      respond_to do |format|
        format.html do
          redirect_to resource, flash:
            { success: t('media.images.delete.success') }
        end
        format.json { head :no_content }
      end
    end

    private

    def imageable_resource
      klass = 'image'
      id_key = params.keys.find { |x| x.downcase.match('[a-z]+_id') }
      id = params[id_key]
      klass = id_key.downcase.match('([a-z]+)_id')[1]
      "Media::#{klass.classify}".constantize.find(id)
    rescue
      not_found(klass) && (return)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      not_found('image') && return unless Image.exists? params[:id]
      @image = Image.find(params[:id])
    end

    # Access the resource for this controller.
    def resource
      @image
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def image_params
      params.require(:image).permit(:url, :resource_id, :resource_type)
    end

    def image_url(image, options = {})
      klass = image.resource.class.name.demodulize.parameterize
      send("#{klass}_image_url", image.resource, image, options)
    end
  end
end
