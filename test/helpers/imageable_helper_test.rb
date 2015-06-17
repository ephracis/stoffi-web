require 'test_helper'
require 'font-awesome-sass'

class ImageableHelperTest < ActionView::TestCase
	
	include I18nHelper
	include FontAwesome::Sass::Rails::ViewHelpers
	
	test 'should create editable image' do
		a = Album.first
		path = a.image(:huge)
		options = { width: 100, height: 100 }
		i = editable_image_tag a, :huge, options
		assert i.include?(image_tag(path, options))
	end
end