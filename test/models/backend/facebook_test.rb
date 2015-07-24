require 'test_helper'
require 'test_helpers/facebook_helper'

class FacebookTest < ActiveSupport::TestCase
  
  include Backends::FacebookTestHelpers
  include Rails.application.routes.url_helpers
  
  test "should get names" do
    stub_oauth "/me?fields=name,username",
      { "name" => "Alice Babs", "username" => "alice" }
      
    backend = Backends::Facebook.new
    names = backend.names
    
    assert_equal "alice", names[:username]
    assert_equal "Alice Babs", names[:fullname]
  end
  
  test "should get picture" do
    stub_oauth "/me/picture?type=large&redirect=false",
      { "data" => { "url" => "http://foo.com/pic.jpg" } }
    assert_equal "http://foo.com/pic.jpg", Backends::Facebook.new.picture
  end
  
  test "should share song" do
    message = SecureRandom.urlsafe_base64(5)
    params = {
      link: "http://#{SecureRandom.urlsafe_base64(5)}",
      name: SecureRandom.urlsafe_base64(5),
      caption: SecureRandom.urlsafe_base64(5),
      image: "http://#{SecureRandom.urlsafe_base64(5)}.jpg"
    }
    stub_oauth "/me/feed", {}, method: :post, params: {
      message: message, link: params[:link], name: params[:name],
      caption: params[:caption], picture: params[:image]
    }
    accounts_links(:alice_facebook).share(message, params)
  end
  
  test "should start listen" do
    listen = media_listens(:alice_one_love)
    stub_listen [], method: :post, params: {
      song: song_url(listen.song.id, l: nil), start_time: listen.created_at,
      end_time: listen.ended_at,
    }
    accounts_links(:alice_facebook).start_listen(listen)
  end
  
  test "should end listen by delete" do
    listen = media_listens(:alice_one_love)
    listen.update_attribute(:ended_at, listen.created_at + 2.seconds)
    
    # get listen
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { song: { url: song_url(listen.song.id, l: nil) } }
      }
    ]
    stub_listen response, url: '/me/music.listens?limit=25&offset=0'
    
    # delete listen
    stub_oauth '/bar', {}, method: :delete
    
    accounts_links(:alice_facebook).end_listen(listen)
  end
  
  test "should end listen by update" do
    listen = media_listens(:alice_one_love)
    listen.update_attribute(:ended_at, listen.created_at + 20.seconds)
    
    # get listen
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { song: { url: song_url(listen.song.id, l: nil) } }
      }
    ]
    stub_listen response, url: '/me/music.listens?limit=25&offset=0'
    
    # update listen
    stub_oauth '/bar', {}, method: :post, params: { end_time: listen.ended_at }
    
    accounts_links(:alice_facebook).end_listen(listen)
  end
  
  test "should update listen" do
    listen = media_listens(:alice_not_afraid)
    
    # find listen
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { song: { url: song_url(listen.song.id, l: nil) } }
      }
    ]
    stub_listen response, url: '/me/music.listens?limit=25&offset=0'
    stub_listen response, url: '/me/music.listens?limit=25&offset=0'
    
    # update listen
    stub_oauth '/bar', {}, method: :post, params: { end_time: listen.ended_at }
    
    accounts_links(:alice_facebook).update_listen(listen)
  end
  
  test "should delete listen" do
    listen = media_listens(:alice_one_love)
    
    # find listen
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { song: { url: song_url(listen.song.id, l: nil) } }
      }
    ]
    stub_listen response, url: '/me/music.listens?limit=25&offset=0'
    
    # delete listen
    stub_oauth '/bar', {}, method: :delete
    
    accounts_links(:alice_facebook).delete_listen(listen)
  end
  
  test "should find listen" do
    url = 'http://test.com/abc'
    stub_listen 25, url: '/me/music.listens?limit=25&offset=0'
    stub_listen 25, url: '/me/music.listens?limit=25&offset=25'
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { song: { url: url } }
      }, {}, {}
    ]
    stub_listen response, url: '/me/music.listens?limit=25&offset=50'
    
    id = Backends::Facebook.new.send "find_listen_by_url", url
    assert_equal 'bar', id, "Didn't return correct ID"
  end
  
  test "should create playlist" do
    playlist = media_playlists(:foo)
    stub_playlist [], method: :post,
      params: { playlist: playlist_url(playlist.id, l: nil) }
    accounts_links(:alice_facebook).create_playlist(playlist)
  end
  
  test "should update playlist" do
    playlist = media_playlists(:bar)
    
    # find playlist
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { playlist: { url: playlist_url(playlist.id, l: nil) } }
      }
    ]
    stub_playlists response, url: '/me/music.playlists?limit=25&offset=0'
    
    # scrub playlist
    stub_oauth '/?id=bar&scrape=true', {}
    
    accounts_links(:alice_facebook).update_playlist(playlist)
  end
  
  test "should update new playlist" do
    playlist = media_playlists(:foo)
    
    # find playlist
    stub_playlists 25, url: '/me/music.playlists?limit=25&offset=0'
    stub_playlists 0, url: '/me/music.playlists?limit=25&offset=25'
    
    # create playlist
    stub_playlist [], method: :post,
      params: { playlist: playlist_url(playlist.id, l: nil) }
      
    accounts_links(:alice_facebook).update_playlist(playlist)
  end
  
  test "should delete playlist" do
    playlist = media_playlists(:bar)
    
    # find playlist
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { playlist: { url: playlist_url(playlist.id, l: nil) } }
      }
    ]
    stub_playlists response, url: '/me/music.playlists?limit=25&offset=0'
    
    # delete playlist
    stub_oauth '/bar', {}, method: :delete
    
    accounts_links(:alice_facebook).delete_playlist(playlist)
  end
  
  test "should find playlist" do
    url = 'http://test.com/abc'
    stub_playlists 25, url: '/me/music.playlists?limit=25&offset=0'
    stub_playlists 25, url: '/me/music.playlists?limit=25&offset=25'
    response = [
      {}, {}, {},
      {
        id: 'bar',
        application: { id: Rails.application.secrets.oa_cred['facebook']['id'] },
        data: { playlist: { url: url } }
      }, {}, {}
    ]
    stub_playlists response, url: '/me/music.playlists?limit=25&offset=50'
    
    id = Backends::Facebook.new.send "find_playlist_by_url", url
    assert_equal 'bar', id, "Didn't return correct ID"
  end
  
  test "should get encrypted uid" do
    stub_oauth '/dmp?fields=third_party_id', { 'third_party_id' => 'foo' }
    uid = Backends::Facebook.new.encrypted_uid
    assert_equal 'foo', uid
  end
  
end