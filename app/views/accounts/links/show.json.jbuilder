json.(@link, :id, :provider, :display, :uid)
[:listens, :shares, :playlists, :button].each do |setting|
  json.(@link, "enable_#{setting}") if @link.respond_to? "#{setting}?"
end