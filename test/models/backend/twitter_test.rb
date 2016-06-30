# frozen_string_literal: true
require 'test_helper'
require 'test_helpers/backend_helper'

class TwitterTest < ActiveSupport::TestCase
  include Backends::TestHelpers
  include Rails.application.routes.url_helpers

  test 'should get names' do
    stub_oauth '/1.1/users/show.json?user_id=my_id',
               'name' => 'Alice Babs', 'screen_name' => 'alice'

    backend = Backends::Twitter.new
    backend.user_id = 'my_id'
    assert_equal 'Alice Babs', backend.name
  end

  test 'should get picture' do
    stub_oauth '/1.1/users/show.json?user_id=my_id',
               'profile_image_url_https' => 'https://foo.com/pic.jpg'
    backend = Backends::Twitter.new
    backend.user_id = 'my_id'
    assert_equal 'https://foo.com/pic.jpg', backend.picture
  end

  test 'should share song' do
    message = SecureRandom.urlsafe_base64(5)
    stub_oauth '/1.1/statuses/update.json', {},
               params: { status: message }, method: :post
    accounts_links(:alice_twitter).share(message)
  end
end
