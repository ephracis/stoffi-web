# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Handle requests to the app.
#
# TODO: split
class ApplicationController < ActionController::Base
  # we need number_to_currency for our title formatting
  include ActionView::Helpers::NumberHelper

  # we need to fix `url_for` and other helpers.
  # include Media::PlaylistsController::Helpers

  include I18nController
  include PlaylistHelperController
  include DeviceHelperController

  require 'geoip'

  # prevent csrf
  protect_from_forgery
  after_action :set_csrf_cookie

  before_action :auth_with_params,
                :ensure_device_id,
                :classify_device,
                :set_locale,
                :check_tracking,
                :check_old_browsers

  # put the CSRF token into a cookie for Angular to use
  # when sending requests to the API.
  def set_csrf_cookie
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def owns(resource, id)
    o = resource.find(id)
    return false if current_user.nil? || o.nil?
    return false unless o.user == current_user
    true
  end

  def not_found(resource)
    @resource = resource
    render '/errors/404.html', status: :not_found
  end

  alias current_app current_client_application

  # authenticate a user if the correct parameters are given
  # we need this to let applications login using their saved
  # tokens.
  #
  # We should require HTTPS for this one (in case we turn it
  # off on the whole site.
  def auth_with_params
    if params[:oauth_token] && params[:oauth_secret_token]
      t = params[:oauth_token]
      s = params[:oauth_secret_token]
      token = OauthToken.find_by(token: t, secret: s)
      if token
        sign_in(token.user)
      else
        redirect_to new_user_session_path
      end
    end
  end

  # we require each oauth request to carry a device_id
  # parameter so we can keep track of devices.
  def ensure_device_id
    if oauth?.is_a?(Accounts::AccessToken)

      if should_require_device_id?
        begin
          @current_device = get_device
          if @current_device
            @current_device.poke(current_capp, request.ip)
          else
            error = { message: 'Missing device ID. Every request must have a '\
                               'device_id parameter.', code: 1 }
          end
        rescue
          error = { message: "Invalid device ID. It either doesn't exist or "\
                             'is not owned by current user.', code: 2 }
        end
      end

      render(json: error, status: :unprocessable_entity) && return if error

    end
  end

  # Get the current device of the visitor.
  attr_reader :current_device

  def ensure_admin
    access_denied unless current_user.admin?
  end

  def access_denied
    if user_signed_in?
      redirect_to dashboard_path

    elsif request.format.to_sym == :json
      error = { message: 'authentication error', code: 401 }
      self.status = 401
      self.content_type = request.format
      self.response_body = error.to_json

    else
      session['user_return_to'] = request.url
      redirect_to new_user_session_path
    end
  end

  def authenticate_user!(_opts = {})
    access_denied unless user_signed_in?
  end

  # map stuff between what oauth-plugin expects and what Devise gives:
  alias logged_in? user_signed_in?
  alias login_required authenticate_user!

  def current_user=(user)
    sign_in(:user, user)
  end

  def current_user
    user = super
    return current_token.user unless user || !current_token
    user
  rescue
    nil
  end

  protected

  # Ensure that the request contains a valid CSRF token.
  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def verify_authenticity_token
    verified_request? || oauth? ||
      raise(ActionController::InvalidAuthenticityToken)
  end

  private

  def after_sign_in_path_for(resource)
    set_locale
    saved = stored_location_for(resource)
    return saved if saved
    dashboard_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    set_locale
    request.referer || new_user_session_path
  end

  def check_tracking
    dnt = request.env['HTTP_DNT']
    @track = true
    @track = false if dnt == '1' && @browser != 'ie'
  end

  # Gets the origin country of an IP
  def origin_country(ip = nil)
    ip ||= request.remote_ip
    db = File.join(Rails.root, 'lib', 'assets', 'GeoIP.dat')
    GeoIP.new(db).country(ip) if File.exist? db
  end
  helper_method :origin_country

  # Gets the origin city (and country) from an IP
  def origin_city(ip)
    db = File.join(Rails.root, 'lib', 'assets', 'GeoLiteCity.dat')
    GeoIP.new(db).city(ip) if File.exist? db
  end
  helper_method :origin_city

  # Gets the origin network from an IP
  def origin_network(ip)
    db = File.join(Rails.root, 'lib', 'assets', 'GeoIPASNum.dat')
    GeoIP.new(db).asn(ip) if File.exist? db
  end
  helper_method :origin_network

  # Gets the origin position from an IP
  def origin_position(ip)
    default = { longitude: -1, latitude: -1 }
    db = File.join(Rails.root, 'lib', 'assets', 'GeoLiteCity.dat')
    if File.exist? db
      city = GeoIP.new(db).city(ip)
      return default unless city
      return { longitude: city[:longitude], latitude: city[:latitude] }
    else
      default
    end
  end
  helper_method :origin_network

  def classify_device
    @ua = request.user_agent.to_s.downcase

    case @ua
    when /facebook/i
      @browser = 'facebook'
    when /googlebot/i
      @browser = 'google'
    when /chrome/i
      @browser = 'chrome'
    when /opera/i
      @browser = 'opera'
    when /firefox/i
      @browser = 'firefox'
    when /safari/i, /applewebkit/i
      @browser = 'safari'
    when /msie/i, /trident/i
      @browser = 'internet-explorer'
    else
      @browser = 'unknown'
    end

    case @ua
    when /windows nt 6.3/i
      @os = 'windows 8.1'
    when /windows nt 6.2/i
      @os = 'windows 8'
    when /windows nt 6.1/i
      @os = 'windows 7'
    when /windows nt 6./i
      @os = 'windows new'
    when /windows phone/i
      @os = 'windows phone'
    when /windows/i
      @os = 'windows old'
    when /iphone/i, /ipad/i
      @os = 'ios'
    when /android/i
      @os = 'android'
    when /linux/i
      @os = 'linux'
    when /mac/i
      @os = 'mac'
    else
      @os = 'unknown'
    end
  end

  def check_old_browsers
    return if cookies[:skip_old]
    return if %w(facebook google).include? @browser
    return if controller_name == 'static' && action_name == 'old'
    return if @ua.include?('capybara-webkit')

    if params[:dangerous]
      cookies[:skip_old] = '1'
    else
      begin
        old = case @browser
              when 'internet-explorer'
                v = @ua.match(/ msie (\d+\.\d+)/)[1].to_i
                v < 9

              when 'firefox'
                v = @ua.match(%r{ firefox\/(\d[\d\.]*\d)})[1].to_i
                v < 10

              when 'opera'
                ua = @ua.split
                ua.pop if ua[-1] =~ /\[\w\w\]/
                v = if ua[-1].start_with? 'version/'
                      ua[-1].split('/')[1].to_i
                    elsif ua[-2] == 'opera'
                      ua[-1].to_i
                    elsif ua[0].start_with? 'opera/'
                      ua[0].split('/')[1].to_i
                    else
                      0
                    end
                v < 10

              when 'chrome'
                v = @ua.match(%r{ chrome\/(\d[\d\.]*\d) })[1].to_i
                v < 10

              when 'safari'
                m = @ua.match(%r{webkit\/(\d[\d\.]*\d)})
                v = m ? m[1].to_i : 0
                v < (@os == 'windows' ? 534 : 537)

              else
                false
              end

        if old
          logger.info 'render warning of old browser instead of requested page'
          render('static/old', l: I18n.locale) && return
        end
      rescue StandardError
        false
      end
    end
  end

  def adaptable_format?
    request.format == :html || request.format.to_s == '*/*'
  end

  def pagination_params
    max_l = 50
    min_l = 1
    default_l = 25

    min_o = 0
    default_o = 0

    l = params[:limit] || default_l
    o = params[:offset] || default_o

    l = l.to_i
    o = o.to_i

    l = max_l if l > max_l
    l = min_l if l < min_l
    o = min_o if o < min_o

    [l, o]
  end

  def https_get(url)
    json = {}
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri.to_s
      res = http.request request
      data = res.body

      json = JSON.parse(data)
    end
    json
  end

  # Get device from either header or param
  def find_device
    [
      params[:device_id],
      request.env['HTTP_X_DEVICE_ID']
    ].each do |f|
      return Device.find(f) if f.present?
    end
  end

  def should_require_device_id?
    controller_name == 'devices' ||
      (
        controller_name == 'registrations' &&
        action_name == 'show' &&
        (params[:id].blank? || params[:id] == 'me')
      ) ||
      (
        controller_name == 'playlists' &&
        (action_name.to_s.in? %w(index show by))
      )
  end
end

# Extend the string class.
class String
  def possessive
    l = ''
    l = I18n.locale.to_s if I18n
    case l

    when 'se'
      self + case self[-1, 1]
             when 's' then ''
             else 's'
             end

    else
      self + case self[-1, 1]
             when 's' then "'"
             else "'s"
             end
    end
  end

  def downcase
    tr 'A-ZÅÄÖƐƆŊ', 'a-zåäöɛɔŋ'
  end
end

module ActionView
  module Helpers
    # Extend the form helper.
    class FormBuilder
      def d(str)
        return str unless str.is_a? String

        next_str = HTMLEntities.new.decode(str)
        while next_str != str
          str = next_str
          next_str = HTMLEntities.new.decode(str)
        end
        next_str
      end

      def decoded_text_field(method, options = {})
        options[:value] = d(@object[method])
        text_field(method, options)
      end
    end
  end
end

module ActiveRecord
  module Associations
    # Extend associations.
    class CollectionProxy
      def to_s
        map(&:to_s).join(', ')
      end
    end
  end

  # Extend associations.
  class AssociationRelation
    def to_s
      map(&:to_s).join(', ')
    end
  end
end
