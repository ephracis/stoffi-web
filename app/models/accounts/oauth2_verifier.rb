# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # A verifier token for OAuth 2.
  class Oauth2Verifier < OauthToken
    attr_accessor :state

    validates :user, presence: true

    # Exchanges the token by invalidating the current token and creating a new
    # one.
    def exchange!(_params = {})
      OauthToken.transaction do
        token = Oauth2Token.create! user: user, app: app, scope: scope
        invalidate!
        token
      end
    end

    # The token of the verifier.
    def code
      token
    end

    # The URL to redirect to when verification is complete.
    def redirect_url
      callback_url
    end

    # Serializes the verifier token to a HTTP query.
    def to_query
      q = "code=#{token}"
      q << "&state=#{URI.escape(state)}" if @state
      q
    end

    protected

    # Generates the keys and timestamps of the verifier token.
    def generate_keys
      self.token = OAuth::Helper.generate_key(20)[0, 20]
      self.expires_at = 10.minutes.from_now
      self.authorized_at = Time.current
    end
  end
end
