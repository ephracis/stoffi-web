require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
  #include Devise::TestHelpers
  
  setup do
    @admin = users(:alice)
    @user = users(:bob)
    Accounts::Link.any_instance.expects(:name).at_least(0).returns('test name')
  end
  
  test 'get user' do
    sign_in @user
    get 'me.json'
    assert_response :success
    json = JSON::parse(response.body)
    assert_equal @user.id, json['id']
    assert_equal @user.name, json['name']
    assert_equal @user.image, json['image']
    assert_equal @user.created_at, json['created_at']
  end
  
  test "create device" do
    sign_in @user
    assert_difference "@user.devices.count", +1 do
      post 'devices.json', device:
        {
          name: randstr, version: 'test', app_id: App.first.id
        }
    end
    assert_response :created
    body = JSON::parse(response.body)
    assert body['id'].to_i > 0
  end
  
  test 'get device' do
    device = @user.devices.first
    sign_in @user
    get device_url(device, format: :json)
    assert_response :success
    body = JSON::parse(response.body)
    assert_equal device.id, body['id'].to_i
    assert_equal device.name, body['name']
  end
  
  # test 'list links' do
  #   @user = users(:charlie)
  #   sign_in @user
  #   get 'links.json'
  #   assert_response :success
  #   body = JSON::parse(response.body)
  #   assert_equal JSON::parse(@user.links.to_json), body['connected']
  # end
  
  # test 'get link' do
  #   @user = users(:charlie)
  #   link = @user.links.first
  #   sign_in @user
  #   get link_url(link, format: :json)
  #   assert_response :success
  #   assert_equal link.to_json, response.body
  # end
  # 
  # test 'update link' do
  #   @user = users(:charlie)
  #   link = @user.links.first
  #   send_listens = link.send_listens
  #   sign_in @user
  #   patch link_url(link, format: :json), { link: { send_listens: !send_listens } }
  #   assert_response :success
  #   assert_equal !send_listens, Accounts::Link.find(link.id).send_listens, "Didn't change setting"
  # end
  # 
  # test 'delete link' do
  #   @user = users(:charlie)
  #   link = @user.links.first
  #   sign_in @user
  #   assert_difference "@user.links.count", -1 do
  #     delete link_url(link, format: :json)
  #   end
  #   assert_response :no_content
  # end
  
  # test 'list playlists' do
  #   
  # end
  # 
  # test 'get playlist' do
  #   
  # end
  # 
  # test 'get someone elses playlist' do
  #   
  # end
  # 
  # test 'follow playlist' do
  #   
  # end
  # 
  # test 'unfollow playlist' do
  #   
  # end
  # 
  # test 'create playlist' do
  #   
  # end
  # 
  # test 'update playlist' do
  #   
  # end
  # 
  # test 'share playlist' do
  #   
  # end
  # 
  # test 'delete playlist' do
  #   
  # end
  # 
  # test 'get sync profile' do
  #   
  # end
  # 
  # test 'update sync profile' do
  #   
  # end
  # 
  # test 'start listen' do
  #   
  # end
  # 
  # test 'update listen' do
  #   
  # end
  # 
  # test 'end listen' do
  #   
  # end
  # 
  # test 'delete listen' do
  #   
  # end
  # 
  # test 'share song' do
  #   
  # end
end
