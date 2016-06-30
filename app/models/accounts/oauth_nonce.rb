# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # A nonce for use with OAuth requests.
  class OauthNonce < ActiveRecord::Base
    validates :nonce, :timestamp, presence: true
    validates :nonce, uniqueness: { scope: :timestamp }

    # Remembers a nonce and it's associated timestamp.
    # Returns false if it has already been used.
    def self.remember(nonce, timestamp)
      oauth_nonce = OauthNonce.create(nonce: nonce, timestamp: timestamp)
      return false if oauth_nonce.new_record?
      oauth_nonce
    end
  end
end
