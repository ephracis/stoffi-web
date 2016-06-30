# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # An access token for OAuth 2.
  class Oauth2Token < AccessToken
    attr_accessor :state

    # Serializes the access token to JSON.
    def as_json(_options = {})
      d = { access_token: token, token_type: 'bearer' }
      d[:expires_in] = expires_in if expires_at
      d
    end

    # Serializes the access token to a HTTP query.
    def to_query
      q = "access_token=#{token}&token_type=bearer"
      q << "&state=#{URI.escape(state)}" if @state
      q << "&expires_in=#{expires_in}" if expires_at
      q << "&scope=#{URI.escape(scope)}" if scope
      q
    end

    # The time left before the token expires (in seconds).
    def expires_in
      expires_at.to_i - Time.now.to_i
    end
  end
end
