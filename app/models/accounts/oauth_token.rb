# Copyright (c) 2015 Simplare

module Accounts
  
  # A token for use with OAuth requests.
  class OauthToken < ActiveRecord::Base
    
    # associations
    belongs_to :app
    belongs_to :user
    
    # validations
    validates :token, uniqueness: true
    validates :app, :token, presence: true
    
    # hooks
    before_validation :generate_keys, on: :create
    
    # stuff is hardcoded in the gem, so we have to do this...
    alias_method :client_application, :app

    # Whether or not the token has been invalidated.
    def invalidated?
      invalidated_at != nil
    end

    # Invalidates the token.
    def invalidate!
      update_attribute(:invalidated_at, Time.now)
    end

    # Whether or not the token has been authorized.
    def authorized?
      authorized_at != nil && !invalidated?
    end

    # Gets the HTTP query for sending to a requesting client app.
    def to_query
      "oauth_token=#{token}&oauth_token_secret=#{secret}"
    end
  
    # All valid and authorized tokens.
    def self.valid
      where(invalidated_at: nil).where.not(authorized_at: nil)
    end

    protected

    # Generates the token's keys.
    def generate_keys
      self.token = OAuth::Helper.generate_key(40)[0,40]
      self.secret = OAuth::Helper.generate_key(40)[0,40]
    end
  end
end