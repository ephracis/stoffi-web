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
  
  ### INDEX ###

  test "should get index logged out" do
    get :index
    assert_response :success
    assert_nil assigns(:user_owns)
    assert_not_nil assigns(:all_time)
  end

  test "should get index logged in" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:user_owns)
    assert_not_nil assigns(:all_time)
    assert_equal @user.playlists.count, assigns(:user_owns).count
  end
  
  ### MINE ###

  test "should not get mine logged out" do
    get :mine
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end

  test "should get mine logged in" do
    sign_in @user
    get :mine, format: :json
    assert_response :success
    assert_not_nil assigns(:playlists)
    assert_equal @user.playlists.count, assigns(:playlists).count
  end
  
  ### FOLLOWING ###

  test "should not get following logged out" do
    get :following
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end

  test "should get following logged in" do
    sign_in @user
    get :following, format: :json
    assert_response :success
    assert_not_nil assigns(:playlists)
    assigns(:playlists).each do |playlist|
      assert @user.follows?(playlist)
    end
  end
  
  ### SHOW ###
  
  test "should get show logged out" do
    get :show, id: @playlist
    assert_response :success
  end
  
  test "should get show logged in" do
    sign_in @user
    get :show, id: @playlist
    assert_response :success
  end
  
  test "should not show non-existent" do
    get :show, id: randstr(special: false, upper: false, lower: false)
    assert_response :not_found
  end
  
  ### NEW ###

  test "should not get new logged out" do
    get :new
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should get new logged in" do
    sign_in @user
    get :new
    assert_response :success
  end
  
  ### CREATE ###
  
  test "should not create playlist logged out" do
    post :create, playlist: @playlist.attributes
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end

  test "should create playlist" do
    Accounts::Link.any_instance.stubs(:create_playlist).returns(nil)
    stub_youtube_video snippet: { title: randstr(special: false) }
    sign_in @user
    assert_difference 'Media::Playlist.count', 1 do
      assert_difference "Media::Song.count", 1 do
        post :create, { playlist: { name: randstr }, songs:
          [
            # TODO: add support for URL backends
            #{ path: "http://#{randstr special: false}/foo.mp3" },
            { path: "#{randstr special: false}.mp3" }, # ignore this one
            { path: "stoffi:song:youtube:#{randstr special: false}" }
          ] }
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
      post :create, { playlist: @playlist.attributes, songs: songs }
    end
    
    assert_not_nil assigns(:playlist), 'Did not assign @playlist'
    assert_redirected_to playlist_path(assigns(:playlist)), 'Did not redirect to playlist'
    assert_equal 3, assigns(:playlist).songs.count, 'Did not merge songs'
  end
  
  ### EDIT ###

  test "should get edit" do
    sign_in @user
    get :edit, id: @playlist
    assert_response :success
  end
  
  test "should not get edit logged out" do
    get :edit, id: @playlist
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should not get edit for someone else's playlist" do
    sign_in users(:bob)
    get :edit, id: @playlist
    assert_response :not_found
  end
  
  ### UPDATE ###

  test "should update playlist" do
    Accounts::Link.any_instance.stubs(:update_playlist).returns(nil)
    sign_in @user
    put :update, id: @playlist, playlist: @playlist.attributes
    assert_response :found
    assert_redirected_to playlist_path(assigns(:playlist))
  end
  
  test "should not update playlist logged out" do
    put :update, id: @playlist, playlist: @playlist.attributes
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  test "should not update someone else's playlist" do
    sign_in users(:bob)
    put :update, id: @playlist, playlist: @playlist.attributes
    assert_response :not_found
  end
  
  ### DESTROY ###

  test "should destroy playlist" do
    Accounts::Link.any_instance.stubs(:delete_playlist).returns(nil)
    sign_in @user
    assert_difference('Media::Playlist.count', -1) do
      delete :destroy, id: @playlist
    end
    assert_redirected_to playlists_path
  end
  
  test "should not destroy playlist logged out" do
    delete :destroy, id: @playlist
    assert_redirected_to new_user_session_path, "Not redirected to login page"
  end
  
  ### FOLLOW / UNFOLLOW ###
    
  test "should follow playlist" do
    sign_in users(:bob)
    assert @playlist.is_public, "Test assumes playlist is public"
    put :follow, id: @playlist
    assert_response :found
    assert users(:bob).follows?(@playlist), "Not following playlist"
  end

  test "should unfollow playlist" do
      sign_in @user
      put :follow, id: @playlist2.to_param
      assert_redirected_to playlist_path(@playlist2), "Could not follow playlist"
      assert @user.follows?(@playlist2), "Not following playlist"
      delete :destroy, id: @playlist2.to_param
      assert_redirected_to playlist_path(@playlist2), "Could not unfollow playlist"
      get :show, id: @playlist2.to_param
      assert_response :success, "Could not get playlist"
      assert_not @user.follows?(@playlist2), "Still following playlist"
    end
  
end