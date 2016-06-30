# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Backends are responsible for communicating with external services.
#
# Backends are primarily used by `Source`s, `Search`es and `Link`s.
#
# ### `Source`
# A `Source` of a resource can use an instance of a backend to generate its
# resource, by giving the backend the type and id of the resource. It does this
# by calling the `generate_resource` method.
#
# ### `Search`
# A `Search` will call `search` on the backend and use the returned hashes to
# create resources, `Source`s and `Image`s.
#
# ### `Link`
# A `Link`, which holds a `User`'s authentication data for an external service,
# can call upon a backend to access data at that external service on the behalf
# of the user. Examples are a user's avatar, playlists or contact lists.
module Backends
  # The base class of backends.
  class Base
    # When an instance of this backend is used as a source for a resource,
    # `:resource_type` is used to specify the class of that resource.
    attr_accessor :resource_type

    # When an instance of this backend is used as a source for a resource,
    # `:resource_id` is used to specify the id of the resource at the backend
    # site.
    attr_accessor :resource_id

    # Used to authenticate a user at the backend.
    attr_accessor :access_token

    # Used to authenticate a user at the backend.
    attr_accessor :access_token_secret

    # Used to aquire a new `access_token` and `access_token_secret` once they
    # expire.
    attr_accessor :refresh_token

    # The authenticated user's ID at the backend.
    attr_accessor :user_id

    # Create a new instance of this backend.
    #
    # This ties the backend to a specific resource.
    def initialize(type = nil, id = nil)
      @resource_type = type
      @resource_id = id
    end

    # Generate a new resource from the data at the backend.
    #
    # This requires that `resource_type` and `resource_id` is set.
    def generate_resource
      raise "The #{self} backend does not support resource generation"
    end

    # The user's profile picture.
    #
    # This requires that `access_token` and `access_token_secret` is set.
    def picture
      nil
    end

    # The user's name.
    #
    # This requires that `access_token` and `access_token_secret` is set.
    def name
      nil
    end

    # A list of the user's friends.
    #
    # This requires that `access_token` and `access_token_secret` is set.
    def friends
      []
    end

    %w(shares listens playlists button).each do |resources|
      define_method "#{resources}?" do
        false
      end
    end

    # Aquire a new set of `access_token` and `access_token_secret` using the
    # `refresh_token`.
    def refresh_credentials
      raise 'Not implemented yet'
    end

    # Whether or not a given error message indicates that the failed submission
    # should be retried later.
    #
    # For example it could be that the service is temporarily unavailable or
    # that the credentials have expired and needs to be renewed using
    # `refresh_credentials`.
    def retry_on?(_error)
      false
    end

    # The encrypted ID of the user.
    #
    # Allows us to link web pages or other resources to users at the backend
    # without exposing their ID to visitors.
    #
    # This is currently only used by Facebook via its Open Graph.
    def encrypted_uid
    end

    # A pretty display name of an instance of the backend.
    def to_s
      self.class.to_s
    end

    # A pretty display name of the backend.
    def self.to_s
      'Generic Backend'
    end

    # Search for a query in a given set of categories
    def self.search(_query, _categories)
      raise 'Not implemented yet'
    end

    # Get an array of resources, of type `klass`, with IDs `ids`.
    def self.get_resources(_klass, _ids)
      raise 'Not implemented yet'
    end

    private_class_method

    # Send an authorized GET request to the service.
    def get(path, params = {})
      request(path, :get, params)
    end

    # Send an authorized POST request to the service.
    def post(path, params = {})
      request(path, :post, params)
    end

    # Send an authorized DELETE request to the service.
    def delete(path)
      request(path, :delete, {})
    end

    # Send an authorized request to the service.
    def request(path, method, params)
      if refresh_token && token_expires_at < DateTime.current
        refresh_credentials
      end

      id = self.class.creds['id']
      key = self.class.creds['key']
      url = self.class.creds['url']

      client = OAuth2::Client.new(id, key, site: url,
                                           ssl: { ca_path: '/etc/ssl/certs' })
      token = OAuth2::AccessToken.new(client, access_token,
                                      header_format: 'OAuth %s')

      case method
      when :get
        return token.get(path).parsed

      when :post
        return token.post(path, params).parsed

      when :delete
        return token.delete(path).parsed
      end
    end

    # The API credentials
    def self.creds
      Rails.application.secrets.oa_cred[name.demodulize.downcase]
    end
  end
end
