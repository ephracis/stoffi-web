# frozen_string_literal: true
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should create user' do
    passwd = 'foobar'
    assert_difference('User.count', 1, "Didn't create user") do
      User.create(email: 'foo@bar.com', password: passwd,
                  password_confirmation: passwd)
    end
  end

  test 'should not save user with short password' do
    passwd = 'foo'
    assert_no_difference('User.count', 'Created user with short password') do
      User.create(email: 'foo@bar.com', password: passwd,
                  password_confirmation: passwd)
    end
  end

  test 'should not save user without password' do
    assert_no_difference('User.count', 'Created user without password') do
      User.create(email: 'foo@bar.com')
    end
  end

  test 'should generate slug from email' do
    user = User.create(email: 'foobar.anderson@mail.com',
                       password: '123123', password_confirmation: '123123')
    assert_equal 'foobar-anderson', user.slug
  end

  test 'should generate slug from name' do
    user = User.create(name: 'Foo Bar',
                       password: '123123', password_confirmation: '123123')
    assert_equal 'foo-bar', user.slug
  end

  test "should not generate slug when it's present" do
    user = User.create(name: 'foo bar', slug: 'myslug',
                       password: '123123', password_confirmation: '123123')
    assert_equal 'myslug', user.slug
  end

  test 'should generate a unique slug' do
    user1 = User.new(
      email: 'foo@bar.com',
      password: '123123',
      password_confirmation: '123123'
    )
    user2 = User.new(
      email: 'foo@mail.com',
      password: '123123',
      password_confirmation: '123123'
    )
    user1.save!
    user2.save!
    assert_equal 'foo', user1.slug
    assert_not_equal user1.slug, user2.slug
  end

  test 'slug should be unique' do
    assert_raises ActiveRecord::RecordNotUnique do
      users(:alice).update_attribute(:slug, users(:bob).slug)
    end
  end

  test 'should destroy user' do
    alice = users(:alice)
    bob = users(:bob)
    bob.follow alice.playlists.first
    assert_difference('User.count', -1, "Didn't remove user") do
      assert_difference('bob.followings.count', -1,
                        "Didn't remove following") do
        assert_difference('Media::Playlist.count', -1 * alice.playlists.count,
                          "Didn't remove playlists") do
          alice.destroy
        end
      end
    end
  end

  test 'should fetch gravatar images' do
    alice = users(:alice)
    assert alice.gravatar(:mm).starts_with? 'https://gravatar.com/avatar'
    assert alice.gravatar(:monsterid).starts_with? 'https://gravatar.com/avatar'
    alice.image = 'gravatar'
    assert_equal alice.gravatar(:mm), alice.picture
    alice.image = 'identicon'
    assert_equal alice.gravatar(:identicon), alice.picture
  end

  test 'should get unconnected links' do
    alice = users(:alice)
    unconnected = alice.unconnected_links
    available = Accounts::Link.available # all links

    # ensure connected links are not included
    alice.links.each do |link|
      assert_equal 0, unconnected.select { |l| l[:name] == link.to_s }.length

      # remove this from all links
      available.reject! { |l| l[:name] == link.to_s }
    end

    # ensure that the left-overs (after removing connected) are all included
    available.each do |link|
      assert_includes unconnected, link
    end
  end

  test 'should own' do
    user = users(:alice)
    assert user.owns? user.playlists.first
  end

  test 'should not own' do
    assert_not users(:alice).owns? users(:bob).playlists.first
  end

  test 'nil should not own' do
    assert_not nil.owns? Media::Playlist.first
  end
end
