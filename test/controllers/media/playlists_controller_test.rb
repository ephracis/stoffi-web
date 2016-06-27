require 'test_helper'
require 'test_helpers/youtube_helper'

class Media::PlaylistsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include Backends::YoutubeTestHelpers
  
  setup do
    @playlist = users(:alice).playlists.first
    @playlist2 = users(:bob).playlists.first
    @user = users(:alice)
    #@request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "should generate playlist path" do
    assert_equal '/alice/foo', playlist_path(@playlist)
  end
  
  ### SHOW ###
  
  test "should get show logged out" do
    get :show, user_slug: @playlist.user, playlist_slug: @playlist
    assert_response :success
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, user_slug: @playlist.user, playlist_slug: @playlist
    assert_response :success
  end
  
  test "should not show non-existent" do
    get :show, user_slug: @playlist.user, playlist_slug: rand(1..10000)
    assert_response :not_found
  end
  
  ### NEW ###
  
  test "should not get new logged out" do
    get :new, user_slug: @playlist.user
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should get new logged in" do
    sign_in @user
    get :new, user_slug: @playlist.user
    assert_response :success
  end
  
  ### CREATE ###
  
  test "should not create playlist logged out" do
    post :create, playlist: @playlist.attributes, user_slug: @playlist.user
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should create playlist" do
    Accounts::Link.any_instance.stubs(:create_playlist).returns(nil)
    stub_youtube_video snippet: { title: randstr(special: false) }
    sign_in @user
    assert_difference 'Media::Playlist.count', 1 do
      assert_difference "Media::Song.count", 1 do
        post :create, playlist: { name: randstr }, user_slug: @user, songs:
          [
            # TODO: add support for URL backends
            #{ path: "http://#{randstr special: false}/foo.mp3" },
            { path: "#{randstr special: false}.mp3" }, # ignore this one
            { path: "stoffi:song:youtube:#{randstr special: false}" }
          ]
      end
    end
    
    assert_not_nil assigns(:playlist)
    assert_redirected_to playlist_path(assigns(:playlist))
    assert_equal 1, assigns(:playlist).songs.count,
      "playlist doesn't contain the correct songs"
  end
  
  test "should not create two playlists with same name" do
    Accounts::Link.any_instance.stubs(:update_playlist).returns(nil)
    stub_youtube_video 1
    sign_in @user
    songs = [
      "stoffi:song:youtube:#{randstr special: false, upper: false}",
      "stoffi:song:youtube:#{randstr special: false, upper: false}"
    ]
    assert_no_difference('Media::Playlist.count') do
      post :create, user_slug: @user, songs: songs,
        playlist: @playlist.attributes.slice('name', 'slug', 'is_public', 'filter')
    end
    
    assert_not_nil assigns(:playlist), 'Did not assign @playlist'
    assert_redirected_to playlist_path(assigns(:playlist)), 'Did not redirect to playlist'
    assert_equal 3, assigns(:playlist).songs.count, 'Did not merge songs'
  end
  
  ### EDIT ###
  
  test "should get edit" do
    sign_in @user
    get :edit, playlist_slug: @playlist, user_slug: @user
    assert_response :success
  end
  
  test "should not get edit logged out" do
    get :edit, playlist_slug: @playlist, user_slug: @user
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should not get edit for someone else's playlist" do
    sign_in users(:bob)
    get :edit, playlist_slug: @playlist, user_slug: @playlist.user
    assert_response :not_found
  end
  
  ### UPDATE ###
  
  test "should update playlist" do
    Accounts::Link.any_instance.stubs(:update_playlist).returns(nil)
    sign_in @user
    put :update, playlist_slug: @playlist, user_slug: @playlist.user,
      playlist: @playlist.attributes
    assert_response :found
    assert_redirected_to playlist_path(assigns(:playlist))
  end
  
  test "should not update playlist logged out" do
    put :update, playlist_slug: @playlist, user_slug: @playlist.user,
      playlist: @playlist.attributes
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should not update someone else's playlist" do
    sign_in users(:bob)
    put :update, playlist_slug: @playlist, user_slug: @playlist.user,
      playlist: @playlist.attributes
    assert_response :not_found
  end
  
  ### DESTROY ###
  
  test "should destroy playlist" do
    Accounts::Link.any_instance.stubs(:delete_playlist).returns(nil)
    sign_in @user
    assert_difference('Media::Playlist.count', -1) do
      delete :destroy, playlist_slug: @playlist, user_slug: @playlist.user
    end
    assert_redirected_to playlists_path
  end
  
  test "should not destroy playlist logged out" do
    delete :destroy, playlist_slug: @playlist, user_slug: @playlist.user
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  ### FOLLOW / UNFOLLOW ###
    
  test "should follow playlist" do
    sign_in users(:bob)
    assert @playlist.is_public, "Test assumes playlist is public"
    put :follow, playlist_slug: @playlist, user_slug: @playlist.user
    assert_response :found
    assert users(:bob).follows?(@playlist), "Not following playlist"
  end
  
  test "should unfollow playlist" do
      sign_in @user
      put :follow, playlist_slug: @playlist2, user_slug: @playlist2.user
      assert_redirected_to playlist_path(@playlist2), "Could not follow playlist"
      assert @user.follows?(@playlist2), "Not following playlist"
      delete :destroy, playlist_slug: @playlist2.to_param, user_slug: @playlist2.user
      assert_redirected_to playlist_path(@playlist2), "Could not unfollow playlist"
      get :show, playlist_slug: @playlist2, user_slug: @playlist2.user
      assert_response :success, "Could not get playlist"
      assert_not @user.follows?(@playlist2), "Still following playlist"
  end
  
end