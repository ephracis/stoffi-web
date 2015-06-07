require 'test_helper'

class ImageableTest < ActiveSupport::TestCase
	
	setup do
		@song = songs(:one_love)
	end
	
	test "should create images" do
		assert_difference "@song.images.count", 1, "Didn't create new image" do
			@song.images_hash = { images: [
				{
					url: 'test.com/image.png',
					width: 42,
					height: 42
				}
			] }
		end
		image = Image.find_by(url: 'test.com/image.png')
		assert_includes @song.images, image, "New image was not assigned to song"
	end
	
	test "should not create duplicates" do
		assert_no_difference "@song.images.count", "Created new image with duplicate url" do
			@song.images_hash = { images: [
				{ url: @song.images.first.url }
			] }
		end
	end
	
	test "should update images for existing sizes" do
		assert_no_difference "@song.images.count", "Number of images changed" do
			@song.images_hash = { images: [
				{
					url: 'test.com/image.png',
					width: @song.images.first.width,
					height: @song.images.first.height
				}
			] }
		end
		assert @song.images.any? { |x| x.url == "test.com/image.png" }, "Didn't assign new url"
	end
	
end