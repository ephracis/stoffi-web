# Copyright (c) 2015 Simplare

# Describes an app for accessing the API.
class App < ActiveRecord::Base
  
  include Base
  
  # associations
  belongs_to :user
  with_options dependent: :destroy do |assoc|
    assoc.has_many :tokens, class_name: Accounts::OauthToken
    assoc.has_many :access_tokens, class_name: Accounts::AccessToken
    assoc.has_many :oauth2_verifiers, class_name: Accounts::Oauth2Token
    assoc.has_many :oauth_tokens, class_name: Accounts::OauthToken
  end
  has_many :users, through: :access_tokens
  
  # validations
  validates :name, :website, :key, :secret, presence: true
  validates :key, :name, uniqueness: true

  validates_format_of :website,
    with: /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
  validates_format_of :support_url, :callback_url, :author_url, allow_blank: true,
    with: /\Ahttp(s?):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/i
    
  # hooks
  before_validation :generate_keys, on: :create

  attr_accessor :token_callback_url
  
  searchable do
    text :name, :author, :description
  end
  
  # Gets a list of all apps not added by a given user
  def self.not_added_by(user)
    return self.all if user.blank?
    tokens = Accounts::AccessToken.where(user: user).valid.to_sql
    joins("LEFT JOIN (#{tokens}) oauth_tokens ON oauth_tokens.app_id = apps.id").
    group("apps.id").
    having("count(oauth_tokens.id) = 0")
  end

  # Gets an authorized token given a token key.
  def self.find_token(token_key)
    token = OauthToken.find_by(token: token_key, include: :app)
    if token && token.authorized?
      token
    else
      nil
    end
  end

  # Verifies a request by signing it with OAuth.
  def self.verify_request(request, options = {}, &block)
    begin
      signature = OAuth::Signature.build(request, options, &block)
      return false unless OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      value = signature.verify
      value
    rescue OAuth::Signature::UnknownSignatureMethod => e
      false
    end
  end
  
  def self.permissions
    ["name", "picture", "playlists", "listens", "shares"]
  end

  # The URL to the OAuth server.
  def oauth_server
    @oauth_server ||= OAuth::Server.new("http://beta.stoffiplayer.com")
  end

  # The credentials of the OAuth consumer.
  def credentials
    @oauth_client ||= OAuth::Consumer.new(key, secret)
  end

  # Creates a token for requesting access to the OAuth API.
  #
  # Note: If our application requires passing in extra parameters handle it here
  def create_request_token(params={})
    RequestToken.create app: self, callback_url: self.token_callback_url
  end
  
  def image(size = :huge)
    sizes = {
      tiny: 16,
      small: 32,
      medium: 64,
      large: 128,
      huge: 512
    }
    raise "Invalid icon size: #{size}" unless size.in? sizes
    m = "icon_#{sizes[size]}"
    return send(m) if respond_to?(m) and send(m).present?
    "gfx/icons/#{sizes[size]}/app.png"
  end
  
  def similar
    search = self.search do
      fulltext name.split.join(' or ') do
        phrase_fields name: 5.0
        phrase_slop 2
      end
    end
    search.results
  end
  
  def installed_by?(user)
    return false unless user
    tokens.valid.where(user: user).count > 0
  end

  protected

  # Generate the public and secret API keys for the app.
  def generate_keys
    self.key = OAuth::Helper.generate_key(40)[0,40]
    self.secret = OAuth::Helper.generate_key(40)[0,40]
  end
end
