# frozen_string_literal: true
# A collection of helpers related to GeoIP.
module GeoipHelper
  # Get the country flag for the origin of a given IP-adress.
  def flag_image_tag(ip, options = {})
    country = origin_country(ip)
    code = country.present? ? country.country_code2.to_s : ''
    code.blank? || code == '--' ? '' : image_tag("flags/#{code.downcase}.png",
                                                 options)
  end

  # Get the city of a given IP-adress' origin.
  def city(ip)
    city = origin_city(ip)
    city.present? ? city.city_name : t('cities.unknown')
  end

  # Get the country of a given IP-adress' origin.
  def country(ip)
    country = origin_country(ip)
    code = country.present? ? country.country_code2.to_s : ''
    t((code.blank? || code == '--') ? 'countries.unknown' : "countries.#{code}")
  end

  # Get the network provider of a given IP-adress.
  def network(ip)
    local_nets = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', '127.0.0.1']
    return t 'isp.local' if local_nets.any? { |x| IPAddr.new(x) == ip }
    origin_network(ip).asn
  rescue
    t 'isp.unknown'
  end

  def city_for_coords(long, lat)
    coder = Geokit::Geocoders::GoogleGeocoder
    res = coder.reverse_geocode "#{long}, #{lat}"
    res.city || t('cities.unknown')
  end

  def country_for_coords(long, lat)
    coder = Geokit::Geocoders::GoogleGeocoder
    res = coder.reverse_geocode "#{long}, #{lat}"
    code = res.country_code || 'unknown'
    t("countries.#{code}")
  end

  # Get the country flag for the location of a longitude and latitude..
  def flag_for_coords(long, lat, options = {})
    coder = Geokit::Geocoders::GoogleGeocoder
    res = coder.reverse_geocode "#{long}, #{lat}"
    return '' unless res.country_code
    image_tag("flags/#{res.country_code.downcase}.png", options)
  end
end
