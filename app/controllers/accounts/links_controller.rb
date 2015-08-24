# Copyright (c) 2015 Simplare

module Accounts
  
  # Handle requests for managing links to third party services.
  class LinksController < ApplicationController

    oauthenticate only: [:index, :show, :update, :destroy]
    oauthenticate interactive: true, only: [:edit]
    
    before_filter :ensure_html, only: :create
    before_filter :set_link, only: [ :show, :update, :destroy ]
    
    respond_to :html, :json
  
    # GET /links
    def index
      @links = current_user.links
      @all = { connected: @links, not_connected: [] }
    
      respond_with @links do |format|
        format.html
        format.embedded
        format.xml { render xml: @all }
        format.json { render json: @all }
      end
    end

    # GET /links/1
    def show
      respond_with @link
    end

    # POST /links
    def create
      auth = request.env["omniauth.auth"]
    
      if current_user.present?
        @link = current_user.links.find_by(provider: auth['provider'],
          uid: auth['uid'])
        if @link
          @link.update_credentials(auth)
        else
          @link = current_user.create_link(auth)
        end
      else
        @user = User.find_or_create_with_omniauth(auth)
      
        success = @user
        if success && @user.errors.empty?
          sign_in(:user, @user)
        end
      
        @link = @user.links.first if success
      end
    
      if @link
        # TODO: send to connected devices
        @link.user.playlists.each do |playlist|
          @link.create_playlist(playlist) rescue nil
        end
      end

      respond_with(@link) do |format|
        if @link
          format.html { redirect_to request.env['omniauth.origin'] ||
            edit_user_registration_path + '#accounts' }
          format.json { render json: @link, status: :created, location: @link }
        else
          format.html { redirect_to request.env['omniauth.origin'] ||
            new_user_session_path }
          format.json { render json: @link.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # PUT /links/1
    def update
      success = @link.update_attributes(resource_params)
      # TODO: send to connected devices

      respond_with(@link) do |format|
        if success
          format.html { redirect_to edit_user_registration_path + '#accounts' }
          format.embedded { redirect_to edit_user_registration_path }
          format.json { head :ok }
        else
          format.html { render action: "show" }
          format.json { render json: @link.errors,
            status: :unprocessable_entity }
        end
      end
    end

    # DELETE /links/1
    def destroy
      # TODO: send to connected devices
      @link.user.playlists.each do |playlist|
        @link.delete_playlist(playlist)
      end
      @link.destroy

      respond_with(@link) do |format|
        format.html { redirect_to(edit_user_registration_path + '#accounts') }
        format.embedded { redirect_to(edit_user_registration_path) }
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_link
      not_found('link') and return unless current_user.links.exists? params[:id]
      @link = current_user.links.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def resource_params
      params.require(:link).permit(:send_shares, :send_listens, :send_playlists,
        :show_button)
    end
    
    # Make sure the request is an HTML request.
    def ensure_html
      head :forbidden and return unless request.format == :html
    end
    
  end
end