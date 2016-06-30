# frozen_string_literal: true
json.connected do
  json.array!(current_user.links) do |link|
    json.call(link, :id, :provider, :display, :uid, :picture, :name)
    [:listens, :shares, :playlists, :button].each do |setting|
      json.call(link, "enable_#{setting}") if link.respond_to? "#{setting}?"
    end
    json.url link_url(link, format: :json)
  end
end
json.unconnected do
  json.array!(current_user.unconnected_links) do |link|
    json.display link[:name]
    json.url "/auth/#{link[:slug] || link[:name].downcase}"
  end
end
