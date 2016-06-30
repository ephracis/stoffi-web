# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # Handle requests for managing links to third party services.
  class LinksController < ApplicationController
    oauthenticate only: [:index, :show, :update, :destroy]
    oauthenticate interactive: true, only: [:edit]

    before_action :ensure_html, only: :create
    before_action :set_link, only: [:show, :update, :destroy]

    # GET /links
    def index
      @links = current_user.links
      @all = { connected: @links, not_connected: [] }

      respond_to do |format|
        format.html { redirect_to account_page }
        format.json { render }
      end
    end

    # GET /links/1
    def show
      respond_to do |format|
        format.html { redirect_to account_page }
        format.json { render }
      end
    end

    # POST /links
    def create
      @link = if current_user.present?
                create_link_logged_in
              else
                create_link_logged_out
              end

      initialize_link @link

      redirect_url = request.env['omniauth.origin'] ||
                     (@link ? account_page : new_user_session_path)

      respond_to do |format|
        if @link
          format.html do
            redirect_to redirect_url
          end
          format.json { render json: @link, status: :created, location: @link }
        else
          format.html do
            redirect_to redirect_url
          end
          format.json do
            render json: @link.errors,
                   status: :unprocessable_entity
          end
        end
      end
    end

    # PUT /links/1
    def update
      success = @link.update_attributes(resource_params)
      # TODO: send to connected devices

      respond_to do |format|
        if success
          format.html { redirect_to account_page }
          format.embedded { redirect_to edit_user_registration_path }
          format.json { head :ok }
        else
          format.html { render action: 'show' }
          format.json do
            render json: @link.errors,
                   status: :unprocessable_entity
          end
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

      respond_to do |format|
        format.html { redirect_to account_page }
        format.embedded { redirect_to(edit_user_registration_path) }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_link
      not_found('link') && return unless current_user.links.exists? params[:id]
      @link = current_user.links.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list
    # through.
    def resource_params
      params.require(:link).permit(:enable_shares, :enable_listens,
                                   :enable_playlists, :enable_button)
    end

    # Make sure the request is an HTML request.
    def ensure_html
      head(:forbidden) && return unless request.format == :html
    end

    def account_page
      edit_user_registration_path + '/accounts'
    end

    def create_link_logged_in
      auth = request.env['omniauth.auth']
      l = current_user.links.find_by(provider: auth['provider'],
                                     uid: auth['uid'])
      if l
        l.update_credentials(auth)
      else
        l = current_user.create_link(auth)
      end
      l
    end

    def create_link_logged_out
      @user = User.find_or_create_with_omniauth request.env['omniauth.auth']
      return unless @user
      sign_in(:user, @user) if @user.errors.empty?
      @user.links.first
    end

    def initialize_link(link)
      return unless link
      # TODO: send to connected devices
      link.user.playlists.each do |playlist|
        begin
          link.create_playlist(playlist)
        rescue
          nil
        end
      end
    end
  end
end
