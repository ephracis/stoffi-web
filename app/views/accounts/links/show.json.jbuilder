# frozen_string_literal: true
json.call(@link, :id, :provider, :display, :uid)
[:listens, :shares, :playlists, :button].each do |setting|
  json.call(@link, "enable_#{setting}") if @link.respond_to? "#{setting}?"
end
