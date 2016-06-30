# frozen_string_literal: true
json.call(@user, :id, :created_at, :updated_at, :last_sign_in_at, :avatar,
          :name, :show_ads, :sign_in_count)
json.slug @user.to_param
if current_user.admin?
  json.locked @user.locked_at.present?
  json.admin @user.admin?
end
json.name_source do
  if @user.name_source.present?
    json.call(@user.name_source, :id, :provider, :uid, :name, :display)
  end
end
json.links @user.links do |link|
  json.call(link, :id, :provider, :display, :uid, :picture, :name)
  [:listens, :shares, :playlists, :button].each do |setting|
    json.call(link, "enable_#{setting}") if link.respond_to? "#{setting}?"
  end
  json.url link_url(link, format: :json)
end
json.url url_for(@user)
