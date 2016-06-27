module I18nController
  extend ActiveSupport::Concern
  
  included do
  
    # Set the locale by looking at params, domain, cookie, headers and ip.
    def set_locale
      @parsed_locale =
        extract_locale_from_param ||
        extract_locale_from_tld || 
        extract_locale_from_subdomain ||
        extract_locale_from_cookie ||
        extract_locale_from_accept_language_header ||
        extract_locale_from_ip

      @parsed_locale = @parsed_locale.to_sym if @parsed_locale
      @parsed_locale = nil if @parsed_locale and
        not I18n.available_locales.include?(@parsed_locale)
      I18n.locale = @parsed_locale || I18n.default_locale
    end
  
    # Get locale code from parameter.
    # Sets a cookie if parameter found.
    def extract_locale_from_param
      parsed_locale = params[:l] || params[:locale] || params[:i18n_locale]
      if parsed_locale && 
        cookies[:locale] = parsed_locale
        parsed_locale
      else
        nil
      end
    end
  
    # Get locale code from cookie.
    def extract_locale_from_cookie
      parsed_locale = cookies[:locale]
      if parsed_locale && I18n.available_locales.include?(parsed_locale.to_sym)
        parsed_locale
      else
        nil
      end
    end
  
    # Get locale from top-level domain or return nil if such locale is not available
    # You have to put something like:
    #   127.0.0.1 application.com
    #   127.0.0.1 application.it
    #   127.0.0.1 application.pl
    # in your /etc/hosts file to try this out locally
    def extract_locale_from_tld
      tld = request.host.split('.').last
      parsed_locale = case tld
        when 'hk' then 'cn'
        else tld
      end
      I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale  : nil
    end
  
    # Get locale code from request subdomain (like http://it.application.local:3000)
    # You have to put something like:
    #   127.0.0.1 gr.application.local
    # in your /etc/hosts file to try this out locally
    def extract_locale_from_subdomain
      parsed_locale = request.subdomains.first
      return nil if parsed_locale == nil
      I18n.available_locales.include?(parsed_locale.to_sym) ? parsed_locale : nil
    end
  
    # Get locale code from reading the "Accept-Language" header
    def extract_locale_from_accept_language_header
      begin
        l = request.env['HTTP_ACCEPT_LANGUAGE']
        if l
          parsed_locale = l.scan(/^[a-z]{2}[-_]([a-zA-Z]{2})/).first.first.to_s.downcase
          if parsed_locale && I18n.available_locales.include?(parsed_locale.to_sym)
            return parsed_locale
          else
            return nil
          end
        end
      rescue
        return nil
      end
    end
  
    # Get locale code from looking up location of the IP
    def extract_locale_from_ip
      o = origin_country(request.remote_ip)
      if o
        parsed_locale = o.country_code2.downcase
        if parsed_locale && I18n.available_locales.include?(parsed_locale.to_sym)
          parsed_locale
        else
          nil
        end
      end
    end
    
  end
end