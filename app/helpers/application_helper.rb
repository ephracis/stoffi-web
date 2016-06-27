module ApplicationHelper
  
  def link_to_association(resources)
    x = resources.map { |r| link_to h(r), r, target: '_self' }
      .to_sentence.html_safe
    x.present? ? x : nil
  end
  
  def to_words(number)
    l = case I18n.locale
    when :us, :uk then :en
    else I18n.locale end
    I18n.with_locale(l) { number.to_words }
  end
  
  def pretty_errors(resource = nil)
    errors = []
    if resource and resource.errors and resource.errors.count > 0
      errors << resource.errors.full_messages[0]
    end
    errors << flash[:error] if flash[:error].present?
    errors << flash[:alert] if flash[:alert].present?
    errors.join '<br/>'
  end
  
  def any_errors?(resource = nil)
    flash[:error].present? or
    flash[:alert].present? or
    (resource and resource.errors and resource.errors.count > 0)
  end
  
  def pretty_url(url, remove_www = false)
    if url.starts_with? 'http://'
      url = url[7..-1]
    elsif url.starts_with? 'https://'
      url = url[8..-1]
    end
    
    if url.starts_with?('www.') and remove_www
      url = url[4..-1]
    end
    
    if url.ends_with? '/'
      url = url[0..-2]
    end
    
    return url
  end
  
  # Since we have mutliple root paths depending on the result of the A/B
  # testing, we cannot have it named in routes.rb and instead have to specify
  # it by hand here.
  def root_path
    '/'
  end
  
end
