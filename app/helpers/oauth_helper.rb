module OauthHelper
  
  # Create an OAuth button.
  def oauth_button(provider, options = {})
    options[:path] ||= provider.downcase
    options[:height] ||= 16
    options[:image] ||= "auth_buttons/#{provider.downcase}_#{options[:height]}_white.png"
    options[:tooltip] ||= t('auth.login', service: provider.downcase)
    options[:class] ||= 'auth'
    
    img = image_tag(options[:image], width: options[:width], height: options[:height])
    path = "/auth/#{options[:path]}"
    
    link_to img, path, class: options[:class], title: options[:tooltip]
  end
  
  # Create OAuth buttons.
  def oauth_buttons
    providers = [
      'Facebook', 'Twitter', 'Google',
      'Vimeo', 'LinkedIn', 'SoundCloud'
    ].map do |provider|
      
      path = case provider
      when 'Google' then 'google_oauth2'
      when 'LinkedIn' then 'linked_in'
      else provider.downcase end
        
      oauth_button(provider, path: path)
    end.join.html_safe
  end
  
end