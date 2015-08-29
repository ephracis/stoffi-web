# Copyright (c) 2015 Simplare

# A user account.
class User < ActiveRecord::Base
  
  # concerns
  include Base
  include Followingable
  include Rankable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :omniauthable, :timeoutable and 
  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable, :lockable
   
  with_options dependent: :destroy do |assoc|
    assoc.has_many :links, class_name: Accounts::Link
    assoc.has_many :devices, class_name: Accounts::Device
    assoc.has_many :playlists, class_name: Media::Playlist
    assoc.has_many :shares
    assoc.has_many :listens, class_name: Media::Listen
    assoc.has_many :apps
    assoc.has_many :tokens, -> { order "authorized_at desc" },
      class_name: Accounts::OauthToken
  end
  
  has_many :songs, through: :listens
  has_many :artists, through: :songs

  # The name of the user.
  #
  # Will get the name of the user by either:
  # # Pull the name from a linked account if the user has choosen such a name source.
  # # Return a custom name if the user has provided one.
  # # Look at the email.
  # # Return a default name.
  def name
    if name_source.present?
      providers = ["twitter","facebook","google_oauth2","lastfm","vimeo"]
      p,v = name_source.split("::",2)
      return name_source unless p.in? providers
      l = self.links.find_by(provider: p)
      if l
        names = l.names
        return names[v.to_sym] if names.is_a? Hash and v and names[v.to_sym]
      end
    end
  
    return custom_name if custom_name.present?
    return email.split('@')[0].titleize if email.present?
    User.default_name
  end

  # The default picture of a user.
  # TODO: fix default image for user
  def self.default_pic(size = :huge)
    "gfx/icons/128/user.png"
  end

  # The default name of a user.
  def self.default_name
    "Anon"
  end

  # The unique hash of a user.
  #
  # This is used to identify a unique communication channel for real time communication.
  def unique_hash
    if self.unique_token.blank?
      update_attribute(:unique_token, Devise.friendly_token[0,50].to_s)
    end
    Digest::SHA2.hexdigest(self.unique_token + id.to_s)
  end

  # The amount of fan points the user has.
  def points(artist = nil)
    if artist
      artist.listens.where("user_id = ?", id).count
    else
      listens.count
    end
  end

  # The picture of the user.
  #
  # Will get the picture of the user by either:
  # # Pull the picture from a linked account if the user has choosen such a picture source.
  # # Return a default picture.
  def picture(options = nil)
    size = ""
    size = options[:size] if options != nil
    s = image.to_s
  
    # no image source
    return User.default_pic(size) unless s.present?
  
    # image source is gravatar
    if [:gravatar, :identicon, :monsterid, :wavatar, :retro].include? s.to_sym
      s = s == 'gravatar' ? :mm : s.to_sym
      return gravatar(s)
    
    # image source is something else
    else
      l = self.links.find_by(provider: s)
      return User.default_pic unless l
      pic = l.picture
      return User.default_pic unless pic
      return pic
    end
  
    # should we really ever reach this point?
    return User.default_pic(size)
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
      links.find_by(provider: l[:link_name] || l[:name].downcase) == nil
    end
  end

  # Whether or not the user is an administrator.
  def admin?
    self.admin == true
  end

  # Check if the user owns a given resource.
  def owns?(resource)
    [:owner, :user].each do |m|
      if resource.respond_to? m
        return resource.send(m) == self
      end
    end
  end

  # The gravatar of the user.
  def gravatar(type)
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    force = type == :mm ? "" : "&f=y"
    "https://gravatar.com/avatar/#{gravatar_id}.png?s=128&d=#{type}#{force}"
  end

  # Looks for, and creates if necessary, the user based on an authentication with a third party service.
  def self.find_or_create_with_omniauth(auth)
    link = Accounts::Link.find_by(provider: auth['provider'], uid: auth['uid'])
    user = User.find_by(email: auth['info']['email']) if auth['info']['email']
  
    # link found
    if link
      d = auth['credentials']['expires_at']
      d = DateTime.strptime("#{d}",'%s') if d
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
    pass = Devise.friendly_token[0,20]

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
  
    return user
  end

  # Updates the user resource.
  #
  # If a password change is occuring then the current password
  # will be required unless the user has not already set a
  # password (in case the accounts was created using an authentication
  # with a third party service).
  def update_with_password(params={})
    current_password = params.delete(:current_password) if !params[:current_password].blank?
  
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
  
    result = if has_no_password? || valid_password?(current_password)
      r = update_attributes(params)
      update_attribute(:has_password, true) if params[:password].present?
      r
    else
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      self.attributes = params
      false
    end
  
    clean_up_passwords
    result
  end

  # Whether or not the user has no password set.
  #
  # This happens when the account was created using an account at a third party.
  def has_no_password?
    !self.has_password
  end

  # Creates a link to a third party service given an omniauth hash.
  def create_link(auth)
    exp = auth['credentials']['expires_at']
    exp = DateTime.strptime("#{exp}",'%s') if exp
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
    return nil
  end

  # The options to use when the user is serialized.
  def serialize_options
    {
      except: [
        :has_password, :created_at, :unique_token, :updated_at, :custom_name,
        :admin, :show_ads, :name_source, :image, :email
      
      ],
      methods: [ :kind, :display, :url ]
    }
  end
end

# Allow us to do some checks without having to check
# that current_user != nil.
class NilClass

  # Anonymous users doesn't own anything.
  def owns?(resource) false end
  
  # Anonymous users are never admins.
  def admin?() false end
end