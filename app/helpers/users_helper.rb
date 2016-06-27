module UsersHelper
  
  # Whether or not to show text ads for a given user.
  def text_ads?(user = current_user)
    user.blank? || user.show_ads != "none"
  end
  
  # Whether or not to show image ads for a given user.
  def image_ads?(user = current_user)
    user.blank? || user.show_ads == "all"
  end

  def avatar(user = current_user)
    return user.avatar if user.avatar.present?
    asset_url 'avatars/user.png'
  end

  # Get the username for a given user.
  def username(user = current_user)
    return user.name if user.name.present?
    return user.email.split('@')[0].titleize if user.email.present?
    "Anon"
  end
  
  # Get a link to a user.
  def link_to_user(user = current_user, options = {})
    link_to username(user), user, options
  end

  def avatar_options_for_select
    options = [[t('accounts.settings.general.default_avatar'), '',
                { data: { 'img-src' => image_path('avatars/user.png') } }]]

    current_user.links.each do |l|
      if l.picture.present?
        options << [l.display, l.picture,
                    { data: { 'img-src' => l.picture } } ]
      end
    end

    [:mm, :identicon, :monsterid, :wavatar, :retro].each do |i|
      name = i == :mm ? "Gravatar" : i.to_s
      disp = name.titleize
      disp = 'MonsterID' if name == 'monsterid'
      url = current_user.gravatar i
      options << [disp, url, { data: { 'img-src' => url }}]
    end
    
    options_for_select options, current_user.avatar
  end
  
  def image_options_for_select
    options = [[t('settings.default'), '', { data: { imagesrc: image_path(User.default_pic) }}]]
    
    current_user.links.each do |l|
      if l.picture? and l.picture
        options << [l.display, l.provider, { data: { imagesrc: l.picture }}]
      end
    end
    
    [:mm, :identicon, :monsterid, :wavatar, :retro].each do |i|
      name = i == :mm ? "Gravatar" : i.to_s
      disp = name.titleize
      disp = 'MonsterID' if name == 'monsterid'
      options << [disp, name, { data: { imagesrc: current_user.gravatar(i) }}]
    end
    
    options_for_select options, current_user.image
  end
end
