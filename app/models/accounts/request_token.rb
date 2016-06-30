# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # A request token for OAuth.
  class RequestToken < OauthToken
    attr_accessor :provided_oauth_verifier

    # Authorizes a user for the token.
    def authorize!(user)
      return false if authorized?
      self.user = user
      self.authorized_at = Time.current
      self.verifier = OAuth::Helper.generate_key(20)[0, 20] unless oauth10?
      save
    end

    # Exchanges the request token to an access token.
    def exchange!
      return false unless authorized?
      return false unless oauth10? || verifier == provided_oauth_verifier

      RequestToken.transaction do
        access_token = user.tokens.valid
                           .find_by(app: app, type: 'Accounts::AccessToken')

        if access_token.blank?
          access_token = AccessToken.create(user: user, app: app)
        end

        invalidate!
        access_token
      end
    end

    # Serializes the request token to an HTTP query.
    def to_query
      if oauth10?
        super
      else
        "#{super}&oauth_callback_confirmed=true"
      end
    end

    # Whether or not to redirect the user to a default route after
    # authorization.
    def oob?
      callback_url.nil? || callback_url.casecmp('oob').zero?
    end

    # Whether or not OAuth 1.0 should be used.
    def oauth10?
      (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && callback_url.blank?
    end
  end
end
