# Copyright (c) 2015 Simplare

# Handle requests for sharing resources.
class SharesController < ApplicationController

  oauthenticate only: [ :index, :create, :update, :destroy ]
  before_action :set_resource, only: [ :show, :update, :destroy ]
  before_action :ensure_owner_or_admin, only: [ :update, :destroy ]
  respond_to :html, :json
  
  # GET /shares
  def index
    l, o = pagination_params
    @shares = current_user.shares.limit(l).offset(o)
    respond_with @shares
  end

  # GET /share
  def show
  end

  # POST /shares
  def create
    @share = current_user.shares.new(share_params)
    @share.device = current_device
    # TODO: verify resource
    success = @share.save
    
    if success
      current_user.links.each do |link|
        link.share(@share)
      end
    end
    
    # TODO: send to connected devices
    
    respond_with @share
  end

  # PUT /shares/1
  def update
    success = @share.update(share_params)
    # TODO: send to connected devices
    respond_with @share
  end

  # DELETE /shares/1
  def destroy
    @share.destroy
    # TODO: send to connected devices
    respond_with @share
  end
  
  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_resource
    not_found('share') and return unless Share.exists? params[:id]
    @share = Share.find(params[:id])
  end
    
  # Ensure that the current user is either the owner of `@share` or admin.
  def ensure_owner_or_admin
    unless current_user.admin? or @share.user == current_user
      not_found('share') and return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def share_params
    params.require(:share).permit(:resource_type, :resource_id, :message)
  end
  
  
end
