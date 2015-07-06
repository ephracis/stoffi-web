require 'test_helper'

class SortableTest < ActiveSupport::TestCase
	
	setup do
		@album = albums(:best_of_bob_marley)
	end
	
	test "should sort songs" do
		current_order = @album.songs.map(&:id)
		new_order = current_order.shuffle
		
		# verify current order
		assert_equal current_order, @album.songs.map(&:id), "Wasn't in correct original order"
		
		# sort
		@album.sort :songs, new_order
		
		# verify new order
		assert_equal new_order, @album.ordered_songs.map(&:id), "Didn't change to correct order"
	end
	
end