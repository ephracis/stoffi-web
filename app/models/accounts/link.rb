# frozen_string_literal: true
# Copyright (c) 2015 Simplare

module Accounts
  # A link between a user and a third party account.
  class Link < ActiveRecord::Base
    # concerns
    include Base

    # associations
    belongs_to :user
    has_many :backlogs, dependent: :destroy, class_name: 'LinkBacklog'

    # validations
    validates :provider, presence: true

    # The string to display to users for representing the resource.
    def to_s
      self.class.pretty_name(provider)
    end
    alias display to_s

    # Update the authentication credentials from a hash.
    #
    # The hash should follow the format as what's returned from the `omniauth`
    # gem after successful authentication.
    #
    # After update, all failed submissions in the backlog will be retried.
    def update_credentials(auth)
      exp = auth['credentials']['expires_at']
      exp = DateTime.strptime(exp.to_s, '%s') if exp
      update_attributes(
        access_token: auth['credentials']['token'],
        access_token_secret: auth['credentials']['secret'],
        refresh_token: auth['credentials']['refresh_token'],
        token_expires_at: exp
      )
      retry_failed_submissions
    end

    %w(listens shares playlists button).each do |resources|
      define_method "#{resources}?" do
        backend.send("#{resources}?")
      end

      define_method "#{resources}_enabled?" do
        send("enable_#{resources}") && send("#{resources}?")
      end
    end

    # The user's profile picture on the third party account.
    delegate :picture, to: :backend

    # The user's name on the third party account.
    delegate :name, to: :backend

    # The most recent error message in the `backlog`.
    def error
      backlogs.order(:created_at).last.error if backlogs.count > 0
    end

    # Share a resource.
    def share(message = nil, backend_options = {})
      backend.share(message, backend_options) if shares?
    end

    # Let the service know that the user has started to play a song.
    def start_listen(l)
      backend.start_listen(l) if listens?
    rescue StandardError => e
      catch_error(l, e)
    end

    # Let the service know that the user has paused, resumed, or otherwise
    # updated a currently active song.
    def update_listen(l)
      backend.update_listen(l) if listens?
    rescue StandardError => e
      catch_error(l, e)
    end

    # Let the service know that the user has stopped listen to a song.
    def end_listen(l)
      backend.end_listen(l) if listens?
    rescue StandardError => e
      catch_error(l, e)
    end

    # Remove that a song was listened to on the service.
    #
    # Used when the song was skipped or not played for long enough.
    def delete_listen(l)
      backend.delete_listen(l) if listens?
    end

    # Let the service know that the user just created a playlist.
    def create_playlist(p)
      backend.create_playlist(p) if playlists?
    rescue StandardError => e
      catch_error(p, e)
    end

    # Let the service know that the user just updated a playlist.
    def update_playlist(p)
      backend.update_playlist(p) if playlists?
    rescue StandardError => e
      catch_error(p, e)
    end

    # Let the service know that the user just removed a playlist.
    def delete_playlist(p)
      backend.delete_playlist(p) if playlists?
    end

    def encrypted_uid
      update_attribute(:encrypted_uid, backend.encrypted_uid) unless super
      super
    end

    # A list of services currently supported.
    def self.available
      [
        { name: 'Twitter' },
        { name: 'Facebook' },
        { name: 'Google', slug: 'google_oauth2' },
        { name: 'Vimeo' },
        { name: 'SoundCloud' },
        { name: 'Last.fm', slug: :lastfm, icon: :lastfm },
        { name: 'Weibo' },
        { name: 'Windows Live', slug: :windowslive }
      ]
    end

    # The display name of a given provider.
    def self.pretty_name(provider)
      case provider
      when 'google_oauth2' then 'Google'
      when 'linked_in' then 'LinkedIn'
      when 'soundcloud' then 'SoundCloud'
      when 'lastfm' then 'Last.fm'
      when 'myspace' then 'MySpace'
      when 'linkedin' then 'LinkedIn'
      when 'vkontakte' then 'vKontakte'
      when 'windowslive' then 'Live'
      else provider.titleize
      end
    end

    private

    # Get the backend of the link.
    def backend
      unless @backend
        begin
          @backend = "Backends::#{provider.camelize}".constantize.new
        rescue
          @backend = Backends::Base.new
        end
      end

      # Some backends uses a `refresh_token` to limit the validity of the
      # `access_token`. If the `access_token` has expired, a new one must be
      # retrieved using the `refresh_token`.
      if refresh_token && token_expires_at < DateTime.current
        update_attributes backend.refresh_credentials(refresh_token)
      end

      @backend.access_token = access_token
      @backend.access_token_secret = access_token_secret
      @backend.user_id = uid

      @backend
    end

    # Go through the `backlog` and retry the failed submissions.
    def retry_failed_submissions
      retried = []
      backlogs.each do |backlog|
        next unless backlog.resource

        # only resubmit each resource once
        next if retried.include? backlog.resource

        retry_failed_submission(backlog.resource)
        retried << backlog.resource
      end

      # clear pending submissions
      backlogs.destroy_all
    end

    # Retry a specific failed submission of a given resource.
    def retry_failed_submission(resource)
      case resource.class.name

      when 'Share' then
        share(resource)

      when 'Media::Listen'
        update_listen(resource)

      when 'Media::Playlist'
        update_playlist(resource)

      end
    end

    # Catch an exception that has occured when trying to send a resource to the
    # backend service.
    #
    # This will save the resource and its exception onto the backlog, for later
    # retries.
    def catch_error(resource, exception)
      raise exception if Rails.env.test?

      # extract error message from JSON response
      json = JSON.parse exception.message.split("\n")[1]
      error = json['error']['message']

      # create and save new backlog item if backend thinks we should
      bl = backlogs.new(resource: resource, error: error)
      bl.save if backend.retry_on?(error)
    rescue StandardError => e
      raise e if Rails.env.test?
      logger.error "failed to catch error: #{exception.message}"
    end
  end
end
