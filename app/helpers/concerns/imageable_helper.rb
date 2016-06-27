module Concerns::ImageableHelper
  
  # Display an image for a given resource.
  #
  # If the resource has no image, a default image will be displayed from
  # `assets/images/RESOURCE_CLASS.png`, for example
  # `assets/images/media/song.png`.
  #
  def image_for(resource)
    img = resource.image rescue nil
    return img if img.present?
  end
  
  def image_tag_for(resource, symbol, options = {})
    img = image_for(resource)
    return image_tag(img, options) if img.present?
    content_tag :span, '', class: "fa fa-lg fa-fw fa-#{symbol}"
  end
  
end