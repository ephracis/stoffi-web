# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Handle requests for getting charts.
class ChartsController < ApplicationController
  oauthenticate
  before_action :verify_admin, except: [:listens_for_user, :songs_for_user,
                                        :albums_for_user, :artists_for_user,
                                        :playlists_for_user, :genres_for_user,
                                        :top_listeners]

  def listens_for_user
    @days = current_user.listens.where('created_at > ?', 1.year.ago)
                        .group_by_day(:created_at)
  end

  def songs_for_user
    @songs = Media::Song.rank.for_user(current_user).limit(10)
  end

  def artists_for_user
    @artists = Media::Artist.rank.for_user(current_user).limit(10)
  end

  def albums_for_user
    @albums = Media::Album.rank.for_user(current_user).limit(10)
  end

  def playlists_for_user
    @playlists = Media::Playlist.rank.for_user(current_user).limit(10)
  end

  def genres_for_user
    @genres = Media::Genre.rank.for_user(current_user).limit(10)
  end

  def top_listeners
    @users = User.rank.limit(10)
  end

  def active_users
    @users = User.order(sign_in_count: :desc).limit(10)
  end

  private

  def verify_admin
    return true if signed_in? && current_user.admin?

    respond_to do |format|
      format.html { redirect_to :new_user_session }
      format.json { head :forbidden }
      format.xml { head :forbidden }
    end
  end
end
