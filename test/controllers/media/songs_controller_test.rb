require 'test_helper'

class Media::SongsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup do
    @song = media_songs(:not_afraid)
    @user = users(:bob)
    @admin = users(:alice)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:songs)
  end
  
  test "should show song" do
    get :show, id: @song
    assert_response :success
  end
  
  test "should show archetype" do
    real_song = media_songs(:one_love)
    @song.duplicate_of real_song
    get :show, id: @song
    assert_redirected_to song_path(real_song)
  end
  
  test "should not update song when signed out" do
    patch :update, id: @song, song: { title: @song.title }
    assert_redirected_to new_user_session_path
  end
  
  test "should not update song when user" do
    sign_in @user
    patch :update, id: @song, song: { title: 'foo' }
    assert_redirected_to dashboard_path
    assert_not_equal 'foo', assigns(:song).title
  end
  
  test "should update song when admin" do
    sign_in @admin
    new_title = randstr
    patch :update, id: @song, song: { title: new_title }
    assert_redirected_to song_path(assigns(:song))
    assert_equal new_title, assigns(:song).title
  end
  
  test "should change artists" do
    sign_in @admin
    patch :update, id: @song, artists: [ {name: 'foo'}, {name: 'bar'} ], song: { title: @song.title }
    assert_redirected_to song_path(assigns(:song))
    assert_equal 2, assigns(:song).artists.count
    assert_includes assigns(:song).artists.map(&:name), 'foo'
    assert_includes assigns(:song).artists.map(&:name), 'bar'
  end

  test "should mark as duplicate" do
    sign_in @admin
    assert_not @song.duplicate?, "Was marked as duplicate before test"
    patch :update, id: @song, song: { archetype: media_songs(:no_woman_no_cry) }
    assert_redirected_to song_path(Media::Song.unscoped.find(@song.id))
    assert assigns(:song).duplicate?, "Didn't mark as duplicate"
  end
  
  test "should unmark as duplicate" do
    sign_in @admin
    @song.duplicate_of media_songs(:no_woman_no_cry)
    assert @song.duplicate?, "Wasn't marked as duplicate before test"
    patch :update, id: @song, song: { archetype: '' }
    assert_redirected_to song_path(@song)
    assert_not assigns(:song).duplicate?, "Didn't unmark as duplicate"
  end
end
