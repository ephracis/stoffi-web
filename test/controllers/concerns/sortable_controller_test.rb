require 'test_helper'

class SortableControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @admin = users(:alice)
    @album = media_albums(:best_of_bob_marley)
    @controller = Media::AlbumsController.new
  end

  test "should order on sort request" do
    sign_in @admin
    
    current_order = @album.songs.map(&:id)
    new_order = current_order.shuffle
    
    # verify current order
    assert_equal current_order, @album.songs.map(&:id), "Wasn't in correct original order"
    
    # sort
    patch :sort, id: @album, format: :json, song: new_order
    assert_response :success
    
    # verify new order
    assert_equal new_order, @album.ordered_songs.map(&:id), "Didn't change to correct order"
  end
  
  test "should order on update request" do
    sign_in @admin
    
    current_order = @album.songs.map(&:id)
    new_order = current_order.shuffle
    
    # verify current order
    assert_equal current_order, @album.songs.map(&:id), "Wasn't in correct original order"
    
    # sort
    patch :update, id: @album, format: :json, songs: new_order
    assert_response :success
    
    # verify new order
    assert_equal new_order, @album.ordered_songs.map(&:id), "Didn't change to correct order"
    
  end
end