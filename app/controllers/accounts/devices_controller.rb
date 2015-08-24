# Copyright (c) 2015 Simplare

module Accounts

  # Handle requests for managing devices.
  class DevicesController < ApplicationController

    oauthenticate
    before_action :set_device, only: [:show, :update, :destroy]
    before_action :ensure_owner_or_admin, only: [:show, :update, :destroy]
  
    # GET /devices
    def index
      @devices = current_user.devices
    end

    # GET /devices/1
    def show
    end

    # POST /devices
    def create
      @device = current_user.devices.new(device_params)
      respond_to do |format|
        if @device.save!
          @device.poke current_app, request.ip
          # TODO: send to connected devices
          format.html { redirect_to @device }
          format.json { render :show, status: :created, location: @device }
        else
          format.html { render :index }
          format.json { render json: @device.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # PATCH /devices/1
    def update
      respond_to do |format|
        if @device.update(device_params)
          # TODO: send to connected devices
          format.html { redirect_to @device }
          format.json { render :show, status: :ok, location: @device }
        else
          format.html { render :show }
          format.json { render json: @device.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # DELETE /devices/1
    def destroy
      # TODO: send to connected devices
      @device.destroy
      respond_to do |format|
        format.html { redirect_to devices_url }
        format.json { head :no_content }
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      not_found('device') and return unless Device.exists? params[:id]
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def device_params
      params.require(:device).permit(:name, :version, :app_id)
    end
  
    # Deny access unless the current user is either the owner of the device,
    # or an admin.
    def ensure_owner_or_admin
      access_denied unless current_user.owns?(@device) or current_user.admin?
    end
  end
end