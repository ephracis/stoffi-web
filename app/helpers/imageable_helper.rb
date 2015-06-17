module ImageableHelper
	
	def editable_image_tag(resource, size, options = {})
		img = image_tag resource.image(size), options
		overlay = content_tag :span, class: :overlay do
			content_tag :span, class: 'overlay-content' do
				icon('image')+t('imageable.edit.link')
			end
		end
		content_tag :div, img+overlay, class: 'editable-image', data: {
			imageable_url: url_for([resource, l: current_locale, imageable: true, action: :edit])
		}
	end
end