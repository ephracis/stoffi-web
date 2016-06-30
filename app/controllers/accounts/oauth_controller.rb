# frozen_string_literal: true
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
      if request.get? && params[:oauth_token]
        # Look for existing tokens for the app.
        access_token, request_token = find_existing_tokens
        # If the user has already authorized the app we should just pass it on
        # and not ask again for authorization.
        if access_token && request_token
          authorize_with_existing_token request_token
          return
        end
      end
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
    def authenticate_user(_username, _password)
      user = User.find_by(email: params[:username])
      user if user && user.valid_password?(params[:password])
    end

    private

    # Authorize an app's request given a request token from a previous
    # authorization
    def authorize_with_existing_token(token)
      token.authorize!(current_user)
      @redirect_url = redirect_url_for_token token
      if @redirect_url.blank?
        render action: 'authorize_success'
      else
        redirect_to @redirect_url.to_s
      end
    end

    # Get the URL to redirect to given a request token
    def redirect_url_for_token(token)
      callback_url = token.oob? ? token.app.callback_url : token.callback_url
      redirect_url = URI.parse(callback_url) unless callback_url.blank?
      return redirect_url if redirect_url.blank?
      redirect_url.query += (redirect_url.query.empty? ? '' : '&') +
                            "oauth_token=#{token.token}&"\
                            "oauth_verifier=#{token.verifier}"
      redirect_url
    end

    # Locate tokens from previous authorizations
    def find_existing_tokens
      request_token = RequestToken.find_by!(token: params[:oauth_token])
      if request_token && !request_token.invalidated?
        access_token = current_user.tokens.valid.where(app: request_token.app)
                                   .first
        if access_token && !access_token.invalidated?
          return [access_token, request_token]
        end
      end
    end
  end
end

OAuth::Controllers::ProviderController::ClientApplication = App
RequestToken = Accounts::RequestToken
