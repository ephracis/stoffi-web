# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # An OAuth token for accessing the Stoffi API.
  class AccessToken < OauthToken
    # validations
    validates :user, :secret, presence: true

    # hooks
    before_create :set_authorized_at

    # Implement this to return a hash or array of the capabilities the access
    # token has.
    #
    # This is particularly useful if you have implemented user defined
    # permissions.
    # def capabilities
    #   { invalidate: "/oauth/invalidate", capabilities: "/oauth/capabilities" }
    # end

    protected

    # Sets when a token was authorized.
    def set_authorized_at
      self.authorized_at = Time.current
    end
  end
end
