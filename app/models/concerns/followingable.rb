# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Use this concern to allow a model to follow other resources.
#
# See Followable for details.
module Followingable
  extend ActiveSupport::Concern

  included do
    has_many :followings, as: :follower, dependent: :destroy,
                          class_name: Accounts::Following
  end

  # Returns an array of the resources that is being followed
  def follows
    followings.map(&:followee)
  end

  # Returns an array of the resources of a specific type
  # that are being followed.
  def following(class_name)
    followings.where(followee_type: class_name).map(&:followee)
  end

  # Check if the user follows a given resource
  def follows?(resource)
    in? resource.followers
  end

  # Follow a resource
  def follow(resource)
    # check if self is owner to resource
    [self.class.name.underscore, :owner].each do |method|
      next unless resource.respond_to? method
      if resource.send(method) == self
        raise "Cannot follow #{resource} since it belongs to #{self}"
      end
      break
    end

    Accounts::Following.create(
      follower: self,
      followee: resource
    )
  end

  # Unfollow a resource
  def unfollow(resource)
    followings.where(followee: resource).destroy_all
  end
end

# Extend `nil` to clean up some code.
#
# This:
#
#     current_user.present? and current_user.follows?(MyResource)
#
# becomes:
#
#     current_user.follows?(MyResource)
#
# keeping the code DRY.
#
class NilClass
  # Anonymous users doesn't follow anything.
  #
  # Example:
  #
  #     current_user # nil
  #     current_user.follows?(Media::Playlist.first) # false
  #
  def follows?(_resource)
    false
  end
end
