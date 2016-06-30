# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# A user account.
class User < ActiveRecord::Base
  # concerns
  include Base
  include Followingable
  include Rankable
  include FriendlyId

  # validations
  validates :name, presence: true
  # validates :slug, presence: true, uniqueness: true

  # hooks
  before_validation :generate_name

  # associations
  has_many :links, dependent: :destroy, class_name: Accounts::Link
  has_many :devices, dependent: :destroy, class_name: Accounts::Device
  has_many :playlists, dependent: :destroy, class_name: Media::Playlist
  has_many :shares, dependent: :destroy
  has_many :listens, dependent: :destroy, class_name: Media::Listen
  has_many :apps, dependent: :destroy
  has_many :tokens,
           -> { order 'authorized_at desc' },
           dependent: :destroy,
           class_name: Accounts::OauthToken
  has_many :played_songs, through: :listens, class_name: Media::Song,
                          source: :song
  has_many :played_albums, through: :listens, class_name: Media::Album,
                           source: :album
  has_many :played_playlists, through: :listens, class_name: Media::Playlist,
                              source: :playlist
  has_many :played_artists, through: :played_songs, class_name: Media::Artist,
                            source: :artists
  has_many :activities, as: :owner, class_name: PublicActivity::Activity
  belongs_to :name_source, class_name: Accounts::Link

  # The unique hash of a user.
  #
  # This is used to identify a unique communication channel for real time
  # communication.
  def unique_hash
    if unique_token.blank?
      update_attribute(:unique_token, Devise.friendly_token[0, 50].to_s)
    end
    Digest::SHA2.hexdigest(unique_token + id.to_s)
  end

  # The amount of fan points the user has.
  def points(artist = nil)
    if artist
      artist.listens.where('user_id = ?', id).count
    else
      listens.count
    end
  end

  # Returns all apps of a user.
  #
  # `scope` can be:
  #
  # - `added`
  #   Apps that the user has allowed access to his/her account.
  #
  # - `craeted`
  #   Apps that was created by the user.
  def get_apps(scope)
    case scope
    when :added
      return App.joins(:oauth_tokens).merge(tokens.valid)

    when :created
      return apps
    end
  end

  # Returns all links that the user hasn't yet connected.
  def unconnected_links
    Accounts::Link.available.select do |l|
      links.find_by(provider: l[:slug] || l[:name].downcase).nil?
    end
  end

  # Whether or not the user is an administrator.
  def admin?
    admin == true
  end

  # Check if the user owns a given resource.
  def owns?(resource)
    [:owner, :user].each do |m|
      return resource.send(m) == self if resource.respond_to? m
    end
  end

  # The gravatar of the user.
  def gravatar(type)
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    force = type == :mm ? '' : '&f=y'
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=128&d=#{type}#{force}"
  end

  # Updates the user resource.
  #
  # If a password change is occuring then the current password
  # will be required unless the user has not already set a
  # password (in case the accounts was created using an authentication
  # with a third party service).
  def update_with_password(params = {})
    unless params[:current_password].blank?
      current_password = params.delete(:current_password)
    end

    if params[:password].blank?
      params.delete(:password)
      if params[:password_confirmation].blank?
        params.delete(:password_confirmation)
      end
    end

    result = if no_password? || valid_password?(current_password)
               r = update_attributes(params)
               if params[:password].present?
                 update_attribute(:has_password, true)
               end
               r
             else
               errors.add(:current_password,
                          current_password.blank? ? :blank : :invalid)
               self.attributes = params
               false
             end

    clean_up_passwords
    result
  end

  # Whether or not the user has no password set.
  #
  # This happens when the account was created using an account at a third party.
  def no_password?
    !has_password
  end

  # Creates a link to a third party service given an omniauth hash.
  def create_link(auth)
    exp = auth['credentials']['expires_at']
    exp = DateTime.strptime(exp.to_s, '%s') if exp
    links.create(
      provider: auth['provider'],
      uid: auth['uid'],
      access_token: auth['credentials']['token'],
      access_token_secret: auth['credentials']['secret'],
      refresh_token: auth['credentials']['refresh_token'],
      token_expires_at: exp
    )
  end

  # Fetches the encrypted user ID of the user on a third party.
  #
  # This is used by Facebook to provide the ability to specify
  # the link to the user's profile on Facebook in OpenGraph.
  def encrypted_uid(provider)
    links.each do |link|
      return link.encrypted_uid if link.provider == provider
    end
    nil
  end

  # The options to use when the user is serialized.
  # TODO: remove
  def serialize_options
    {
      except: [
        :has_password, :created_at, :unique_token, :updated_at, :custom_name,
        :admin, :show_ads, :name_source, :image, :email

      ],
      methods: [:kind, :display, :url]
    }
  end

  def to_partial_path
    '/accounts/accounts/user'
  end

  # Looks for, and creates if necessary, the user based on an authentication
  # with a third party service.
  def self.find_or_create_with_omniauth(auth)
    link = Accounts::Link.find_by(provider: auth['provider'], uid: auth['uid'])
    user = User.find_by(email: auth['info']['email']) if auth['info']['email']

    # link found
    if link
      d = auth['credentials']['expires_at']
      d = DateTime.strptime(d.to_s, '%s') if d
      link.update_attributes(
        access_token: auth['credentials']['token'],
        access_token_secret: auth['credentials']['secret'],
        refresh_token: auth['credentials']['refresh_token'],
        token_expires_at: d
      )
      return link.user

    # email already registrered, create link for that user
    elsif auth['info'] && auth['info']['email'] && user
      user.create_link(auth)
      return user

    # create a new user and a link for that user
    else
      return create_with_omniauth(auth)
    end
  end

  # Creates an account by using an authentication to a third party service.
  def self.create_with_omniauth(auth)
    email = auth['info']['email']
    pass = Devise.friendly_token[0, 20]

    # create user
    user = User.new(
      email: email,
      password: pass,
      password_confirmation: pass,
      has_password: false
    )
    user.save(validate: false)

    # create link
    user.create_link(auth)

    user
  end

  # Rank by the number of listens.
  def self.rank(_user = nil)
    select('users.*, COUNT(listens.id) AS listens_count')
      .joins(:listens)
      .group('users.id')
      .order('listens_count DESC')
  end

  ###################### DEPRECATED ######################

  # DEPRECATED
  # Remove after migration 20151115233849 is run.
  def deprecated_name
    if name_source.present?
      providers = %w(twitter facebook google_oauth2 lastfm vimeo)
      p, v = name_source.split('::', 2)
      return name_source unless p.in? providers
      l = links.find_by(provider: p)
      if l
        names = l.names
        return names[v.to_sym] if names.is_a?(Hash) && v && names[v.to_sym]
      end
    end

    return custom_name if custom_name.present?
    return email.split('@')[0].titleize if email.present?
    User.default_name
  end

  # DEPRECATED
  # Remove after migration 20151115233849 is run.
  def self.default_name
    'Anon'
  end

  # DEPRECATED
  # Remove after migration 20151115233849 is run.
  def self.default_pic(_size)
    nil
  end

  # DEPRECATED
  # Remove after migration 20151115233849 is run.
  def picture(options = nil)
    size = ''
    size = options[:size] unless options.nil?
    s = image.to_s

    # no image source
    return User.default_pic(size) unless s.present?

    # image source is gravatar
    if [:gravatar, :identicon, :monsterid, :wavatar, :retro].include? s.to_sym
      s = s == 'gravatar' ? :mm : s.to_sym
      return gravatar(s)

    # image source is something else
    else
      l = links.find_by(provider: s)
      return User.default_pic unless l
      pic = l.picture
      return User.default_pic unless pic
      return pic
    end

    # should we really ever reach this point?
    User.default_pic(size)
  end

  private_class_method

  # Generate a unique slug for the user based on the name or email.
  def generate_slug
    return if slug.present?
    s = 'anon'
    if email.present?
      s = email.split('@')[0].tr('_', '-').parameterize
    elsif name.present?
      s = name.parameterize
    end
    self.slug = s
    i = 0
    while User.find_by(slug: slug)
      i += 1
      self.slug = "#{s}-#{i}"
    end
  end

  # Generate a name based on the email.
  def generate_name
    return if name.present?
    self.name = email.split('@')[0].tr('.', ' ').titleize if email.present?
  end

  # Configure all concerns and extensions.
  def self.configure_concerns
    # Included devise modules. Others available are:
    # - `:token_authenticatable`
    # - `:encryptable`
    # - `:confirmable`
    # - `:omniauthable`
    # - `:timeoutable`
    devise :database_authenticatable,
           :registerable,
           :recoverable,
           :rememberable,
           :trackable,
           :validatable,
           :lockable

    # Enable URLs like `/:name`.
    friendly_id :name, use: :slugged
  end
  configure_concerns
end

# Extend `nil` to clean up some code.
#
# This:
#
#     current_user.present? and current_user.admin?
#
# becomes:
#
#     current_user.admin?
#
class NilClass
  # Anonymous users doesn't own anything.
  #
  # Example:
  #
  #     current_user # nil
  #     current_user.owns?(Media::Playlist.first) # false
  #
  def owns?(_resource)
    false
  end

  # Anonymous users are never admins.
  #
  # Example:
  #
  #     current_user # nil
  #     current_user.admin? # false
  #
  def admin?
    false
  end
end
