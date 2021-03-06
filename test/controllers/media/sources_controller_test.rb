# frozen_string_literal: true
require 'test_helper'

module Media
  class SourcesControllerTest < ActionController::TestCase
    include Devise::TestHelpers
    setup do
      @source = media_sources(:one_love_youtube)
      @user = users(:bob)
      @admin = users(:alice)
    end

    test 'should not get index' do
      assert_raises AbstractController::ActionNotFound do
        get :index, song_id: @source.resource.id
      end
    end

    test 'should get show' do
      get :show, song_id: @source.resource.id, id: @source, format: :json
    end

    test 'should not get edit logged out' do
      get :edit, song_id: @source.resource.id, id: @source
      assert_redirected_to new_user_session_path
    end

    test 'should not get new logged out' do
      get :new, song_id: @source.resource.id
      assert_redirected_to new_user_session_path
    end

    test 'should not get edit as user' do
      sign_in @user
      get :edit, song_id: @source.resource.id, id: @source
      assert_redirected_to dashboard_path
    end

    test 'should not get new as user' do
      sign_in @user
      get :new, song_id: @source.resource.id
      assert_redirected_to dashboard_path
    end

    test 'should get edit as admin' do
      sign_in @admin
      get :edit, song_id: @source.resource.id, id: @source
      assert_response :success
    end

    test 'should get new as admin' do
      sign_in @admin
      get :new, song_id: @source.resource.id
      assert_response :success
    end

    test 'should not create logged out' do
      assert_no_difference('Media::Source.count') do
        post :create, song_id: @source.resource.id, genre: { name: randstr }
      end
      assert_redirected_to new_user_session_path
    end

    test 'should not create as user' do
      sign_in @user
      assert_no_difference('Media::Source.count') do
        post :create, song_id: @source.resource.id, genre: { name: randstr }
      end
      assert_redirected_to dashboard_path
    end

    test 'should create as admin' do
      sign_in @admin
      song = media_songs(:one_love)
      assert_difference('Media::Source.count') do
        post :create, song_id: song.id, format: :json, source: {
          name: 'youtube',
          resource_id: song.id,
          resource_type: 'Media::Song',
          foreign_url: "http://#{randstr special: false}/foo"
        }
      end
      assert_response :success
    end

    test 'should not update logged out' do
      patch :update, song_id: @source.resource.id, id: @source,
                     source: { name: randstr }
      assert_redirected_to new_user_session_path
    end

    test 'should not update as user' do
      sign_in @user
      new_name = randstr
      patch :update, song_id: @source.resource.id, id: @source,
                     source: { name: new_name }
      assert_redirected_to dashboard_path
      assert_not_equal new_name, assigns(:source).name
    end

    test 'should update as admin' do
      sign_in @admin
      new_name = randstr
      patch :update, song_id: @source.resource.id, id: @source,
                     source: { name: new_name }, format: :json
      assert_response :success
      assert_equal new_name, assigns(:source).name
    end

    test 'should not destroy logged out' do
      assert_no_difference('Media::Source.count') do
        delete :destroy, song_id: @source.resource.id, id: @source
      end
      assert_redirected_to new_user_session_path
    end

    test 'should not destroy as user' do
      sign_in @user
      assert_no_difference('Media::Source.count') do
        delete :destroy, song_id: @source.resource.id, id: @source
      end
      assert_redirected_to dashboard_path
    end

    test 'should destroy as admin' do
      sign_in @admin
      assert_difference('Media::Source.count', -1) do
        delete :destroy, song_id: @source.resource.id,
                         id: @source, format: :json
      end
      assert_response :no_content
    end
  end
end
