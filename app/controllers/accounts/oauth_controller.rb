# Copyright (c) 2015 Simplare

require 'oauth/controllers/provider_controller'

module Accounts
  
  # Handle OAuth requests.
  class OauthController < ApplicationController
    include OAuth::Controllers::ProviderController
  
    # Authorize a request token and turn it into an access token.
    #
    # If the user hasn't authorized the token, show a page where the user can
    # either continue (and authorize the app) or cancel the request.
    def authorize
      # Look for existing access token for the app.
      #
      # If the user has already authorized the app we should just pass it on and
      # not ask again for authorization.
      if request.get? and params[:oauth_token]
        @token = RequestToken.find_by!(token: params[:oauth_token])
        if @token and !@token.invalidated?
      
          # find access token for the app
          token = current_user.tokens.valid.where(app: @token.app).first
          
          # check the access token
          if token and !token.invalidated?
            @token.authorize!(current_user)
        
            # redirect according to request token
            callback_url  = @token.oob? ? @token.app.callback_url : @token.callback_url
            @redirect_url = URI.parse(callback_url) unless callback_url.blank?

            unless @redirect_url.blank?
              @redirect_url.query = @redirect_url.query.blank? ?
                "oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}" :
                @redirect_url.query + "&oauth_token=#{@token.token}&oauth_verifier=#{@token.verifier}"
              redirect_to @redirect_url.to_s
            else
              render action: "authorize_success"
            end
            return
            
          end # valid access token
        end # valid request token
      end # GET and token
      
      super
    end

    protected
  
    # Override this to match your authorization page form
    # It currently expects a checkbox called authorize
    def user_authorizes_token?
      params[:authorize] == '1'
    end

    # should authenticate and return a user if valid password.
    # This example should work with most Authlogic or Devise.
    def authenticate_user(username,password)
      user = User.find_by(email: params[:username])
      if user && user.valid_password?(params[:password])
        user
      else
        nil
      end
    end

  end
end

OAuth::Controllers::ProviderController::ClientApplication = App
RequestToken = Accounts::RequestToken