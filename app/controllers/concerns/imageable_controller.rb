module ImageableController
  extend ActiveSupport::Concern
  
  included do
    before_filter :catch_imageable_edit, only: :edit
    before_filter :catch_imageable_update, only: :update
  end
  
  def catch_imageable_edit
    if params.include?(:imageable)
      set_resource
      render partial: '/concerns/imageable/edit',
             object: resource,
             as: :resource and return
    end
  end
  
  def catch_imageable_update
    if params.include?(:imageable)
      set_resource
      return unless params.include?(:image)
      images = []
      params[:image].each do |size,url|
        next if url.blank?
        images << { url: url, width: size, height: size }
      end
      params.delete :images
      resource.images_hash = { images: images }
    end
  end
end