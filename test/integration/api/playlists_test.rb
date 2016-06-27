require 'test_helper'

class PlaylistsTest < ActionDispatch::IntegrationTest
  #include Devise::TestHelpers
  
  setup do
    @admin = users(:alice)
    @user = users(:bob)
    @playlist = @user.playlists.first
  end
  
  test 'get playlist' do
    sign_in @user
    get playlist_path(@playlist, format: :json)
    assert_response :success
    json = JSON::parse(response.body)
    assert_equal @playlist.id, json['id']
    assert_equal @playlist.name, json['name']
    assert_equal @playlist.listens.count, json['listens']
    assert_equal @playlist.created_at, json['created_at']
  end
  
end