require 'test_helper'

class SourcesControllerTest < ActionController::TestCase
	include Devise::TestHelpers
	setup do
		@source = sources(:one_love_youtube)
		@user = users(:bob)
		@admin = users(:alice)
	end

	test "should not get index" do
		assert_raises AbstractController::ActionNotFound do
			get :index
		end
	end

	test "should get show" do
		get :show, id: @source, format: :json
	end

	test "should not get edit" do
		assert_raises AbstractController::ActionNotFound do
			get :edit, id: @source
		end
	end

	test "should not get new" do
		assert_raises AbstractController::ActionNotFound do
			get :new
		end
	end
	
	test "should not create logged out" do
		assert_no_difference('Source.count') do
			post :create, genre: { name: 'Foo' }
		end
		assert_redirected_to new_user_session_path
	end

	test "should not create as user" do
		sign_in @user
		assert_no_difference('Source.count') do
			post :create, genre: { name: 'Foo' }
		end
		assert_redirected_to dashboard_path
	end

	test "should create as admin" do
		sign_in @admin
		assert_difference('Source.count') do
			post :create, source: { name: 'Foo', foreign_url: 'foo/bar/baz' }, format: :json
		end
		assert_response :success
	end

	test "should not update logged out" do
		patch :update, id: @source, source: { name: 'foo' }
		assert_redirected_to new_user_session_path
	end

	test "should not update as user" do
		sign_in @user
		patch :update, id: @source, source: { name: 'foo' }
		assert_redirected_to dashboard_path
		assert_not_equal 'foo', assigns(:source).name
	end

	test "should update as admin" do
		sign_in @admin
		patch :update, id: @source, source: { name: 'foo' }, format: :json
		assert_response :success
		assert_equal 'foo', assigns(:source).name
	end

	test "should not destroy logged out" do
		assert_no_difference('Source.count') do
			delete :destroy, id: @source
		end
		assert_redirected_to new_user_session_path
	end

	test "should not destroy as user" do
		sign_in @user
		assert_no_difference('Source.count') do
			delete :destroy, id: @source
		end
		assert_redirected_to dashboard_path
	end

	test "should destroy as admin" do
		sign_in @admin
		assert_difference('Source.count', -1) do
			delete :destroy, id: @source, format: :json
		end
		assert_response :no_content
	end
end
