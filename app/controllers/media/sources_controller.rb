# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Media
  # The business logic for sources.
  class SourcesController < ApplicationController
    before_action :set_source, except: [:create, :new]
    before_action :ensure_admin, except: :show
    oauthenticate interactive: true, except: :show

    def new
      @source = Source.new
      @source.resource = sourceable_resource
    end

    # POST /sources
    def create
      @source = Source.new(source_params)

      respond_to do |format|
        if @source.save
          format.html do
            redirect_to @source.resource, flash:
              { success: t('media.sources.create.success') }
          end
          format.json { render :show, status: :created, location: @source }
        else
          format.html { render 'new' }
          format.json do
            render json: @source.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # PATCH/PUT /sources/1
    def update
      respond_to do |format|
        if @source.update(source_params)
          format.html do
            redirect_to @source.resource, flash:
              { success: t('media.sources.update.success') }
          end
          format.json { render :show, status: :ok, location: @source }
        else
          format.html { render 'edit' }
          format.json do
            render json: @source.errors, status: :unprocessable_entity
          end
        end
      end
    end

    # DELETE /sources/1
    def destroy
      resource = @source.resource
      @source.destroy
      respond_to do |format|
        format.html do
          redirect_to resource, flash:
            { success: t('media.sources.delete.success') }
        end
        format.json { head :no_content }
      end
    end

    private

    def sourceable_resource
      klass = 'source'
      id_key = params.keys.find { |x| x.downcase.match('[a-z]+_id') }
      id = params[id_key]
      klass = id_key.downcase.match('([a-z]+)_id')[1]
      klass = "Media::#{klass.classify}".constantize
      klass = klass.friendly if klass.respond_to? :friendly
      klass.find(id)
    rescue
      not_found(klass) && (return)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_source
      not_found('source') && return unless Source.exists? params[:id]
      @source = Source.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def source_params
      params.require(:source).permit(:name, :foreign_url, :foreign_id,
                                     :resource_id, :resource_type)
    end

    def source_url(source, options = {})
      klass = source.resource.class.name.demodulize.parameterize
      send("#{klass}_source_url", source.resource, source, options)
    end
  end
end
