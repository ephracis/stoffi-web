# encoding: UTF-8
# frozen_string_literal: true
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_160_105_205_858) do
  create_table 'activities', force: :cascade do |t|
    t.integer  'trackable_id'
    t.string   'trackable_type'
    t.integer  'owner_id'
    t.string   'owner_type'
    t.string   'key'
    t.text     'parameters'
    t.integer  'recipient_id'
    t.string   'recipient_type'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'activities', %w(owner_id owner_type), name: 'index_activities_on_owner_id_and_owner_type'
  add_index 'activities', %w(recipient_id recipient_type), name: 'index_activities_on_recipient_id_and_recipient_type'
  add_index 'activities', %w(trackable_id trackable_type), name: 'index_activities_on_trackable_id_and_trackable_type'

  create_table 'album_tracks', force: :cascade do |t|
    t.integer 'song_id'
    t.integer 'album_id'
    t.integer 'position'
  end

  add_index 'album_tracks', %w(album_id song_id), name: 'by_album_and_song', unique: true

  create_table 'albums', force: :cascade do |t|
    t.string   'title'
    t.integer  'year'
    t.string   'description'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'archetype_id'
    t.string   'archetype_type'
    t.string   'slug'
  end

  add_index 'albums', %w(archetype_id archetype_type), name: 'index_albums_on_archetype_id_and_archetype_type'
  add_index 'albums', ['slug'], name: 'index_albums_on_slug', unique: true

  create_table 'albums_artists', id: false, force: :cascade do |t|
    t.integer 'album_id'
    t.integer 'artist_id'
  end

  add_index 'albums_artists', %w(artist_id album_id), name: 'by_album_and_artist', unique: true

  create_table 'apps', force: :cascade do |t|
    t.string   'name'
    t.string   'website'
    t.string   'support_url'
    t.string   'callback_url'
    t.string   'key',          limit: 40
    t.string   'secret',       limit: 40
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'icon_16'
    t.string   'icon_64'
    t.string   'description'
    t.string   'author'
    t.string   'author_url'
    t.string   'icon_512'
    t.string   'slug'
  end

  add_index 'apps', ['key'], name: 'index_apps_on_key', unique: true
  add_index 'apps', ['slug'], name: 'index_apps_on_slug', unique: true

  create_table 'artists', force: :cascade do |t|
    t.string   'name'
    t.string   'description'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'picture'
    t.integer  'archetype_id'
    t.string   'archetype_type'
    t.string   'slug'
  end

  add_index 'artists', %w(archetype_id archetype_type), name: 'index_artists_on_archetype_id_and_archetype_type'
  add_index 'artists', ['name'], name: 'by_name', unique: true
  add_index 'artists', ['slug'], name: 'index_artists_on_slug', unique: true

  create_table 'artists_genres', id: false, force: :cascade do |t|
    t.integer 'artist_id', null: false
    t.integer 'genre_id',  null: false
  end

  add_index 'artists_genres', %w(genre_id artist_id), name: 'index_artists_genres_on_genre_id_and_artist_id', unique: true

  create_table 'artists_songs', id: false, force: :cascade do |t|
    t.integer 'artist_id'
    t.integer 'song_id'
  end

  add_index 'artists_songs', %w(artist_id song_id), name: 'by_artist_and_song', unique: true

  create_table 'devices', force: :cascade do |t|
    t.string   'name'
    t.integer  'user_id'
    t.string   'last_ip'
    t.string   'version'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'app_id'
    t.string   'status',     default: 'offline'
    t.string   'channels',   default: ''
    t.string   'slug'
  end

  add_index 'devices', %w(slug user_id), name: 'index_devices_on_slug_and_user_id', unique: true

  create_table 'events', force: :cascade do |t|
    t.string   'name'
    t.string   'venue'
    t.decimal  'latitude'
    t.decimal  'longitude'
    t.datetime 'start'
    t.datetime 'stop'
    t.text     'content'
    t.string   'category'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'archetype_id'
    t.string   'archetype_type'
    t.string   'slug'
  end

  add_index 'events', %w(archetype_id archetype_type), name: 'index_events_on_archetype_id_and_archetype_type'
  add_index 'events', ['slug'], name: 'index_events_on_slug', unique: true

  create_table 'followings', force: :cascade do |t|
    t.integer 'follower_id'
    t.string  'follower_type'
    t.integer 'followee_id'
    t.string  'followee_type'
  end

  add_index 'followings', %w(followee_id followee_type), name: 'index_followings_on_followee_id_and_followee_type'
  add_index 'followings', %w(follower_id follower_type), name: 'index_followings_on_follower_id_and_follower_type'

  create_table 'friendly_id_slugs', force: :cascade do |t|
    t.string   'slug',                      null: false
    t.integer  'sluggable_id',              null: false
    t.string   'sluggable_type', limit: 50
    t.string   'scope'
    t.datetime 'created_at'
  end

  add_index 'friendly_id_slugs', %w(slug sluggable_type scope), name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope', unique: true
  add_index 'friendly_id_slugs', %w(slug sluggable_type), name: 'index_friendly_id_slugs_on_slug_and_sluggable_type'
  add_index 'friendly_id_slugs', ['sluggable_id'], name: 'index_friendly_id_slugs_on_sluggable_id'
  add_index 'friendly_id_slugs', ['sluggable_type'], name: 'index_friendly_id_slugs_on_sluggable_type'

  create_table 'genres', force: :cascade do |t|
    t.string   'name'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'archetype_id'
    t.string   'archetype_type'
    t.string   'slug'
  end

  add_index 'genres', %w(archetype_id archetype_type), name: 'index_genres_on_archetype_id_and_archetype_type'
  add_index 'genres', ['slug'], name: 'index_genres_on_slug', unique: true

  create_table 'genres_songs', id: false, force: :cascade do |t|
    t.integer 'song_id',  null: false
    t.integer 'genre_id', null: false
  end

  add_index 'genres_songs', %w(genre_id song_id), name: 'index_genres_songs_on_genre_id_and_song_id', unique: true

  create_table 'images', force: :cascade do |t|
    t.string   'url'
    t.integer  'resource_id'
    t.string   'resource_type'
    t.integer  'width'
    t.integer  'height'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'images', %w(resource_id resource_type), name: 'index_images_on_resource_id_and_resource_type'
  add_index 'images', ['url'], name: 'index_images_on_url', unique: true

  create_table 'link_backlogs', force: :cascade do |t|
    t.integer  'link_id'
    t.integer  'resource_id'
    t.string   'resource_type'
    t.string   'error'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'links', force: :cascade do |t|
    t.integer  'user_id'
    t.string   'provider'
    t.string   'uid'
    t.boolean  'enable_shares',       default: true
    t.boolean  'enable_listens',      default: true
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'enable_playlists',    default: true
    t.boolean  'enable_button',       default: true
    t.string   'refresh_token'
    t.datetime 'token_expires_at'
    t.string   'encrypted_uid'
    t.string   'access_token'
    t.string   'access_token_secret'
  end

  create_table 'listens', force: :cascade do |t|
    t.integer  'user_id'
    t.integer  'song_id'
    t.integer  'playlist_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'device_id'
    t.datetime 'ended_at'
    t.integer  'album_id'
    t.datetime 'started_at'
  end

  create_table 'oauth_nonces', force: :cascade do |t|
    t.string   'nonce'
    t.integer  'timestamp'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'oauth_nonces', %w(nonce timestamp), name: 'index_oauth_nonces_on_nonce_and_timestamp', unique: true

  create_table 'oauth_tokens', force: :cascade do |t|
    t.integer  'user_id'
    t.string   'type', limit: 20
    t.integer  'app_id'
    t.string   'token',          limit: 40
    t.string   'secret',         limit: 40
    t.string   'callback_url'
    t.string   'verifier', limit: 20
    t.string   'scope'
    t.datetime 'authorized_at'
    t.datetime 'invalidated_at'
    t.datetime 'valid_to'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.datetime 'expires_at'
  end

  add_index 'oauth_tokens', ['token'], name: 'index_oauth_tokens_on_token', unique: true

  create_table 'performances', id: false, force: :cascade do |t|
    t.integer 'artist_id', null: false
    t.integer 'event_id',  null: false
  end

  add_index 'performances', %w(artist_id event_id), name: 'index_performances_on_artist_id_and_event_id', unique: true
  add_index 'performances', %w(event_id artist_id), name: 'index_performances_on_event_id_and_artist_id', unique: true

  create_table 'playlists', force: :cascade do |t|
    t.string   'name'
    t.integer  'user_id'
    t.boolean  'is_public', default: true
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'filter'
    t.string   'slug'
  end

  add_index 'playlists', %w(slug user_id), name: 'index_playlists_on_slug_and_user_id', unique: true
  add_index 'playlists', %w(user_id name), name: 'by_user_and_name', unique: true

  create_table 'playlists_songs', force: :cascade do |t|
    t.integer 'playlist_id'
    t.integer 'song_id'
    t.integer 'position'
  end

  add_index 'playlists_songs', %w(playlist_id song_id), name: 'by_playlist_and_song', unique: true

  create_table 'searches', force: :cascade do |t|
    t.string   'query', null: false
    t.integer  'user_id'
    t.string   'page', null: false
    t.decimal  'latitude',   precision: 8, scale: 5
    t.decimal  'longitude',  precision: 8, scale: 5
    t.string   'locale'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'categories'
    t.string   'sources'
  end

  create_table 'shares', force: :cascade do |t|
    t.integer  'user_id'
    t.string   'message'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'device_id'
    t.integer  'resource_id'
    t.string   'resource_type'
  end

  create_table 'songs', force: :cascade do |t|
    t.string   'title'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'archetype_id'
    t.string   'archetype_type'
    t.string   'slug'
  end

  add_index 'songs', %w(archetype_id archetype_type), name: 'index_songs_on_archetype_id_and_archetype_type'
  add_index 'songs', ['slug'], name: 'index_songs_on_slug', unique: true

  create_table 'songs_artists', id: false, force: :cascade do |t|
    t.integer 'song_id'
    t.integer 'artist_id'
  end

  create_table 'sources', force: :cascade do |t|
    t.string   'name'
    t.string   'foreign_id'
    t.string   'foreign_url'
    t.integer  'resource_id'
    t.string   'resource_type'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.decimal  'length'
    t.integer  'popularity', default: 0
  end

  add_index 'sources', %w(resource_id resource_type), name: 'index_sources_on_resource_id_and_resource_type'

  create_table 'users', force: :cascade do |t|
    t.string   'email',                  default: '',    null: false
    t.string   'encrypted_password',     default: '',    null: false
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count', default: 0
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string   'current_sign_in_ip'
    t.string   'last_sign_in_ip'
    t.string   'password_salt'
    t.integer  'failed_attempts', default: 0
    t.string   'unlock_token'
    t.datetime 'locked_at'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'admin', default: false
    t.string   'image'
    t.boolean  'has_password',           default: true
    t.string   'show_ads',               default: 'all'
    t.string   'unique_token'
    t.string   'name'
    t.string   'avatar'
    t.integer  'name_source_id'
    t.string   'slug'
  end

  add_index 'users', ['email'], name: 'index_users_on_email', unique: true
  add_index 'users', ['name_source_id'], name: 'index_users_on_name_source_id'
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  add_index 'users', ['slug'], name: 'index_users_on_slug', unique: true
  add_index 'users', ['unlock_token'], name: 'index_users_on_unlock_token', unique: true
end
