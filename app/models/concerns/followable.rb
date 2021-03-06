# frozen_string_literal: true
# Copyright (c) 2015 Simplare

# Use this concern to allow a model to be followed by other resources.
#
# = Examples
#
# Make users able to follow playlists:
#   class User < ActiveRecord::Base
#     include Followingable
#     # ...
#   end
#   class Playlist < ActiveRecord::Base
#     include Followable
#     followable_by User
#     # ...
#   end
#
# Follow and unfollow something:
#   a.follow b
#   a.unfollow b
#
# Get followed resources:
#   a.follows # includes b
#
# Get followed resource of a given type:
#   a.following(Playlist) # includes b if b.is_a? Playlist
#
# Get following resources:
#   b.followers # includes a
#
# = Setup
#
# You need to add a table to your database:
#   rails g migration CreateFollowings follower:references{polymorphic} \
#         followee:references{polymorphic}
#   rake db:migrate
module Followable
  extend ActiveSupport::Concern

  included do
    has_many :followings, as: :followee, dependent: :destroy,
                          class_name: Accounts::Following
  end

  # Static class methods
  module ClassMethods
    # Make this resource followable by a specific type of resource
    def followable_by(class_name)
      has_many :followers, through: :followings, source_type: class_name
    end
  end
end
